# frozen_string_literal: true

require 'discordrb'

bot = Discordrb::Bot.new(token: File.read('token.secret').strip, intents: [:server_messages])

# Command registrars

# uncomment to delete all commands
#for command in bot.get_application_commands.each
#  bot.delete_application_command command.id
#end

bot.register_application_command(:confess, 'Submit a confession!') do |cmd|
  cmd.string('confession', 'The text of the confession', required: true)
#  cmd.attachment('attachment', 'Optional file to attach with the confession', required: false)
end

# Constants

CONFESS_BUTTON = {label: 'Confess', style: :primary, custom_id: 'confess_button'}
REPLY_BUTTON = {label: 'Reply', style: :secondary, custom_id: 'reply_button'}
REPLY_CONTINUE_BUTTON = {label: 'Reply', style: :secondary, custom_id: 'reply_continue_button'}
CONFESSION_SUBMIT_MESSAGE = {content: 'Your confession has been submitted!', ephemeral: true}
REPLY_SUBMIT_MESSAGE = {content: 'Your reply has been posted! (If you pressed the reply button on the main message and a thread exists, no it hasn\'t. I\'m working on fixing that :P)', ephemeral: true}
MODAL_CONFESSION_TEXT_INPUT = {label: 'Confession message', style: :paragraph, custom_id: 'confession', required: true}
MODAL_REPLY_TEXT_INPUT = {label: 'Reply message', style: :paragraph, custom_id: 'reply', required: true}

# Methods

def send_confession_message(channel, message)
  channel.send_embed('', nil, nil) do |embed, view|
    embed.title = 'Anonymous Confession'
    embed.description = message
    view.row do |r|
      r.button(**CONFESS_BUTTON)
      r.button(**REPLY_BUTTON)
    end
  end
end

def send_confession_reply(channel, reply_message, confession = nil, create_thread_if_not_nil = true)
  reference = nil
  if confession != nil
    if create_thread_if_not_nil
      begin
        channel = channel.start_thread('Confession Replies', 10080, message: confession)
      rescue Discordrb::Errors::UnknownError
        return
      end
    else
      reference = confession
    end
  end
  channel.send_embed('', nil, nil, false, nil, reference) do |embed, view|
    embed.title = 'Anonymous Reply'
    embed.description = reply_message
    view.row do |r|
      r.button(**REPLY_CONTINUE_BUTTON)
    end
  end
end

# Command handlers

bot.application_command(:confess) do |event|
  send_confession_message(event.channel, event.options['confession'])
  event.respond(**CONFESSION_SUBMIT_MESSAGE)
end

# Interaction handlers

# Buttons

bot.button(custom_id: 'confess_button') do |event|
  event.show_modal(title: 'Submitting a confession', custom_id: 'confess_modal') do |modal|
#    def text_input(style:, custom_id:, label: nil, min_length: nil, max_length: nil, required: nil, value: nil, placeholder: nil)
    modal.row do |r|
      r.text_input(**MODAL_CONFESSION_TEXT_INPUT)
    end
  end
end

bot.button(custom_id: 'reply_button') do |event|
  event.show_modal(title: 'Replying to a confession', custom_id: 'reply_modal') do |modal|
    modal.row do |r|
      r.text_input(**MODAL_REPLY_TEXT_INPUT)
    end
  end
end

bot.button(custom_id: 'reply_continue_button') do |event|
  event.show_modal(title: 'Replying to a confession', custom_id: 'reply_continue_modal') do |modal|
    modal.row do |r|
      r.text_input(**MODAL_REPLY_TEXT_INPUT)
    end
  end
end

# Modals

bot.modal_submit(custom_id: 'confess_modal') do |event|
  send_confession_message(event.channel, event.value('confession'))
  event.respond(**CONFESSION_SUBMIT_MESSAGE)
end

bot.modal_submit(custom_id: 'reply_modal') do |event|
  send_confession_reply(event.channel, event.value('reply'), event.message)
  event.respond(**REPLY_SUBMIT_MESSAGE)
end

bot.modal_submit(custom_id: 'reply_continue_modal') do |event|
  send_confession_reply(event.channel, event.value('reply'), event.message, false)
  event.respond(**REPLY_SUBMIT_MESSAGE)
end
bot.run
