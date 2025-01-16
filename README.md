# OpenConfessions
An open-source confessions Discord bot for anonymous messaging

[Invite to your server!](https://discord.com/oauth2/authorize?&client_id=1327822157304037480&scope=bot)

## Why?

There already exists a confessions bot. However, it's proprietary, and they store the authors of all anonymous messages. That's like telling a complete stranger, "hey, can you tell my friend a secret?"

Additionally, the existing has some limitations such as 2 maximum channels that you have to pay to bypass. This bot aims to provide the same features they charge for, for free.

## Self-Hosting

1. Clone this repository on your own server using `git clone https://github.com/Quadragintillion/openconfessions`

2. Install Ruby (on Debian, this is `ruby` and `ruby-dev`)

3. Create an application and a bot for the application on Discord's [developer page](https://discord.com/developers) and copy the token into `token.secret`. The file should contain nothing but the token. You may want to adjust the permissions so other users cannot view its contents.

4. Set up the commands with `bundle exec ruby register-commands.rb`

5. Finally, run the bot with `bundle exec ruby confessions.rb`. It's recommended to use `screen` so it runs in the background instead of stopping when your terminal is closed.
