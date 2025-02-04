# frozen_string_literal: true

require 'discordrb'

bot = Discordrb::Bot.new(token: File.read('token.secret').strip, intents: [:server_messages])

# Constants

CONFESS_BUTTON = {label: 'Confess', style: :primary, custom_id: 'confess_button'}
REPLY_BUTTON = {label: 'Reply', style: :secondary, custom_id: 'reply_button'}
REPLY_CONTINUE_BUTTON = {label: 'Reply', style: :secondary, custom_id: 'reply_continue_button'}
CONFESSION_SUBMIT_MESSAGE = {content: 'Your confession has been submitted!', ephemeral: true}
REPLY_SUBMIT_MESSAGE = {content: 'Your reply has been posted!', ephemeral: true}
IMAGE_INVALID_MESSAGE = {content: 'The image you tried to send seems to be invalid. It must be a URL of an image or GIF.', ephemeral: true}
MODAL_CONFESSION_TEXT_INPUT = {label: 'Confession message', style: :paragraph, custom_id: 'confession', required: true}
MODAL_REPLY_TEXT_INPUT = {label: 'Reply message', style: :paragraph, custom_id: 'reply', required: true}
MODAL_IMAGE_INPUT = {label: 'Optional image', style: :short, custom_id: 'image', required: false}

# Methods

def send_confession_message(channel, message, optional_image = nil)
  channel.send_embed('', nil, nil) do |embed, view|
    embed.title = 'Anonymous Message'
    embed.description = message
    embed.image = {url: optional_image}
    #embed.image = optional_image.nil? ? nil : Discordrb::EmbedImage.new(url: optional_image)
    view.row do |r|
      r.button(**CONFESS_BUTTON)
      r.button(**REPLY_BUTTON)
    end
  end
end

def send_confession_reply(channel, reply_message, optional_image = nil, confession = nil, create_thread_if_not_nil = true)
  reference = nil
  if confession
    if create_thread_if_not_nil
      thread = confession.to_message.thread

      if thread
        channel = thread
      else
        channel = channel.start_thread('Replies', 10080, message: confession)
      end
    else
      reference = confession
    end
  end
  channel.send_embed('', nil, nil, false, nil, reference) do |embed, view|
    embed.title = 'Anonymous Reply'
    embed.description = reply_message
    embed.image = {url: optional_image}
    view.row do |r|
      r.button(**REPLY_CONTINUE_BUTTON)
    end
  end
end

# Command handlers

bot.application_command(:confess) do |event|
  begin
    send_confession_message(event.channel, event.options['confession'], event.options['image'])
    event.respond(**CONFESSION_SUBMIT_MESSAGE)
  rescue Discordrb::Errors::InvalidFormBody
    event.respond(**IMAGE_INVALID_MESSAGE)
  end
end

# Interaction handlers

# Buttons

bot.button(custom_id: 'confess_button') do |event|
  event.show_modal(title: 'Submitting a confession', custom_id: 'confess_modal') do |modal|
    modal.row do |r|
      r.text_input(**MODAL_CONFESSION_TEXT_INPUT)
    end
    modal.row do |r|
      r.text_input(**MODAL_IMAGE_INPUT)
    end
  end
end

bot.button(custom_id: 'reply_button') do |event|
  event.show_modal(title: 'Replying to a confession', custom_id: 'reply_modal') do |modal|
    modal.row do |r|
      r.text_input(**MODAL_REPLY_TEXT_INPUT)
    end
    modal.row do |r|
      r.text_input(**MODAL_IMAGE_INPUT)
    end
  end
end

bot.button(custom_id: 'reply_continue_button') do |event|
  event.show_modal(title: 'Replying to a confession', custom_id: 'reply_continue_modal') do |modal|
    modal.row do |r|
      r.text_input(**MODAL_REPLY_TEXT_INPUT)
    end
    modal.row do |r|
      r.text_input(**MODAL_IMAGE_INPUT)
    end
  end
end

# Modals

bot.modal_submit(custom_id: 'confess_modal') do |event|
  begin
    send_confession_message(event.channel, event.value('confession'), event.value('image'))
    event.respond(**CONFESSION_SUBMIT_MESSAGE)
  rescue Discordrb::Errors::InvalidFormBody
    event.respond(**IMAGE_INVALID_MESSAGE)
  end
end

bot.modal_submit(custom_id: 'reply_modal') do |event|
  begin
    send_confession_reply(event.channel, event.value('reply'), event.value('image'), event.message)
    event.respond(**REPLY_SUBMIT_MESSAGE)
  rescue Discordrb::Errors::InvalidFormBody
    event.respond(**IMAGE_INVALID_MESSAGE)
  end
end

bot.modal_submit(custom_id: 'reply_continue_modal') do |event|
  begin
    send_confession_reply(event.channel, event.value('reply'), event.value('image'), event.message, false)
    event.respond(**REPLY_SUBMIT_MESSAGE)
  rescue Discordrb::Errors::InvalidFormBody
    event.respond(**IMAGE_INVALID_MESSAGE)
  end
end

bot.run
