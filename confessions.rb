# frozen_string_literal: true

puts "Welcome"

require 'discordrb'

bot = Discordrb::Bot.new(token: File.read('token.secret').strip, intents: [:server_messages])

# Command registrars

bot.register_application_command(:example, 'Example commands', server_id: ENV.fetch('SLASH_COMMAND_BOT_SERVER_ID', nil)) do |cmd|
  cmd.subcommand_group(:fun, 'Fun things!') do |group|
    group.subcommand('8ball', 'Shake the magic 8 ball') do |sub|
      sub.string('question', 'Ask a question to receive wisdom', required: true)
    end

    group.subcommand('java', 'What if it was java?')

    group.subcommand('calculator', 'do math!') do |sub|
      sub.integer('first', 'First number')
      sub.string('operation', 'What to do', choices: { times: '*', divided_by: '/', plus: '+', minus: '-' })
      sub.integer('second', 'Second number')
    end

    group.subcommand('button-test', 'Test a button!')
  end
end

bot.register_application_command(:spongecase, 'Are you mocking me?', server_id: ENV.fetch('SLASH_COMMAND_BOT_SERVER_ID', nil)) do |cmd|
  cmd.string('message', 'Message to spongecase')
  cmd.boolean('with_picture', 'Show the mocking sponge?')
end

bot.register_application_command(:confess, 'Submit a confession!', server_id: ENV.fetch('SLASH_COMMAND_BOT_SERVER_ID', nil)) do |cmd|
  cmd.string('confession', 'The text of the confession', required: true)
end

# Command handlers

bot.application_command(:spongecase) do |event|
  ops = %i[upcase downcase]
  text = event.options['message'].chars.map { |x| x.__send__(ops.sample) }.join
  event.respond(content: text)

  event.send_message(content: 'https://pyxis.nymag.com/v1/imgs/09c/923/65324bb3906b6865f904a72f8f8a908541-16-spongebob-explainer.rsquare.w700.jpg') if event.options['with_picture']
end

bot.application_command(:confess) do |event|
  bot.send_message(event.channel, event.options['confession'])
  event.respond(content: 'Your confession has been submitted!', ephemeral: true)
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

bot.select_menu(custom_id: 'test_select') do |event|
  event.respond(content: "You selected: #{event.values.join(', ')}")
end

bot.run
