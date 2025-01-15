# frozen_string_literal: true

require 'discordrb'

bot = Discordrb::Bot.new(token: File.read('token.secret').strip, intents: [:server_messages])

# Command registrars

# uncomment to delete all commands
#for command in bot.get_application_commands.each
#  bot.delete_application_command command.id
#end

bot.register_application_command(:confess, 'Submit a confession!', server_id: ENV.fetch('SLASH_COMMAND_BOT_SERVER_ID', nil)) do |cmd|
  cmd.string('confession', 'The text of the confession', required: true)
#  cmd.attachment('attachment', 'Optional file to attach with the confession', required: false)
end

# Methods

def send_confession_message(channel, message)
  channel.send_embed('', nil, nil) do |embed, view|
    embed.title = 'Anonymous Confession'
    embed.description = message
    view.row do |r|
      r.button(label: 'Confess', style: :primary, custom_id: 'confess_button:912')
      r.button(label: 'Reply', style: :secondary, custom_id: 'reply_button:432')
    end
  end
end

# Command handlers

bot.application_command(:confess) do |event|
  send_confession_message(event.channel, event.options['confession'])
  event.respond(content: 'Your confession has been submitted!', ephemeral: true)
end

# Interaction handlers

# Buttons

bot.button(custom_id: /^confess_button:/) do |event|
  event.show_modal(title: 'test', custom_id: 'confess_modal:55') do |modal|
#    def text_input(style:, custom_id:, label: nil, min_length: nil, max_length: nil, required: nil, value: nil, placeholder: nil)
    modal.row do |r|
      r.text_input(label: 'Text of the confession', style: :paragraph, custom_id: 'confession', required: true)
    end
  end
end

bot.button(custom_id: /^test_button:/) do |event|
  num = event.interaction.button.custom_id.split(':')[1].to_i

  event.update_message(content: num.to_s) do |_, view|
    view.row do |row|
      row.button(label: '-', style: :danger, custom_id: "test_button:#{num - 1}")
      row.button(label: '+', style: :success, custom_id: "test_button:#{num + 1}")
    end
  end
end

# Modals

bot.modal_submit(custom_id: /^confess_modal:/) do |event|
  send_confession_message(event.channel, event.value('confession'))
  event.respond(content: 'Your confession has been submitted!', ephemeral: true)
end

bot.run
