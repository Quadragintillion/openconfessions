# frozen_string_literal: true

require 'discordrb'

bot = Discordrb::Bot.new(token: File.read('token.secret').strip, intents: [:server_messages])

# Command registrars

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

##
# CONFESSION COMMAND
##

#bot.application_command(:confess) do |event|
#  bot.send_message(
#    event.channel.id,
#    event.options['confession'],
#    components: [
#      Discordrb::Components::ActionRow.new(
#        components: [
#          Discordrb::Components::Button.new('Submit a confession!', style: :primary, custom_id: 'submit_button:1'),
#          Discordrb::Components::Button.new('Reply', style: :secondary, custom_id: 'reply_button:1')
#        ]
#      )
#    ]
#  )
#  event.respond(content: 'Your confession has been submitted!', ephemeral: true)
#end

bot.application_command(:confess) do |event|
  components = [
    'type' => 1,
    'components' => [
#    Discordrb::Components::Button.new('Submit a confession!', style: :primary, custom_id: 'submit_button:1'),
#    Discordrb::Components::Button.new('Reply', style: :secondary, custom_id: 'reply_button:1')
    {
      'type' => 2,
      'label' => 'Submit a confession!',
      'style' => 1,
      'custom_id' => 'submit_button:1'
    },
    {
      'type' => 2,
      'label' => 'Reply',
      'style' => 2,
      'custom_id' => 'reply_button:1'
    }
    ]
  ]

  bot.send_message(
    event.channel.id,
    event.options['confession'],
    false,
    nil,
    event.options['attachment'],
    nil,
    nil,
    [
      Discordrb::Components::ActionRow.new(
        #Discordrb::Components::Button.new('Submit a confession!', style: :primary, custom_id: 'submit_button:1'),
        #Discordrb::Components::Button.new('Reply', style: :secondary, custom_id: 'reply_button:1')
        {'components' => components}, bot
      )
    ]
  )
  
  event.respond(content: 'Your confession has been submitted!', ephemeral: true)
end






bot.button(custom_id: /^submit_button:/) do |event|
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
