require 'discordrb'

bot = Discordrb::Bot.new(token: File.read('token.secret').strip, intents: [:server_messages])

# Delete all currently registered commands
for command in bot.get_application_commands.each
  bot.delete_application_command command.id
end

bot.register_application_command(:confess, 'Submit a confession!') do |cmd|
  cmd.string('confession', 'The text of the confession', required: true)
  cmd.string('image', 'Optional image/GIF to attach to the confession', required: false)
end
