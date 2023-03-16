module Contexts
  module GroupContext
    extend ActiveSupport::Concern

    def add_group(group_name)
      group = ::Group.create!(name: group_name, chat_id: mention_bot.chat.id)
      mention_bot.send_message(text: I18n.t('telegram.group_created', group_name: group.name))

      delete_context
    rescue ActiveRecord::RecordInvalid => e
      mention_bot.send_message(text: e.record.errors.full_messages.join("\n"))
    end

    def edit_group(new_name)
      group = mention_bot.chat.groups.find_by!(name: mention_bot.target)
      group.name = new_name
      group.save!

      mention_bot.send_message(text: I18n.t('telegram.group_updated'))

      mention_bot.delete_target
      delete_context
    rescue ActiveRecord::RecordNotFound => e
      mention_bot.send_message(text: I18n.t('telegram.group_not_found'))
    rescue ActiveRecord::RecordInvalid => e
      mention_bot.send_message(text: e.record.errors.full_messages.join("\n"))
    end

    def add_clients(client_list)
      unless /\A((@[a-zA-Z0-9_-]+) ?)+\z/.match(client_list)
        return mention_bot.send_message(text: I18n.t('telegram.wrong_format'))
      end

      clients = client_list.gsub('@', '').split
      group = mention_bot.chat.groups.find_by!(name: mention_bot.target)
      users = mention_bot.chat.users.where(telegram_username: clients)

      users.each do |user|
        group.users << user
        mention_bot.send_message(
          text: I18n.t('telegram.user_added', username: user.telegram_username, group_name: group.name)
        )
      rescue ActiveRecord::RecordInvalid => e
        mention_bot.send_message(text: e.record.errors.full_messages.join("\n"))
      end

      mention_bot.delete_target
      delete_context
    rescue ActiveRecord::RecordNotFound => e
      mention_bot.send_message(text: I18n.t('telegram.group_not_found'))
    end
  end
end
