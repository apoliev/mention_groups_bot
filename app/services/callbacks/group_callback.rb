module Callbacks
  module GroupCallback
    extend ActiveSupport::Concern

    def all_groups
      groups = mention_bot.chat.groups.order(:id)

      if groups.present?
        {
          text: I18n.t('telegram.choose_group'),
          reply_markup: {
            inline_keyboard: groups.each_slice(2).map do |batch|
              batch.map do |group|
                { text: group.name, callback_data: "groups:#{group.name}" }
              end
            end
          }
        }
      else
        { text: I18n.t('telegram.admin_group_not_exist') }
      end
    end

    def groups
      mention_bot.send_message(**all_groups)
    end

    def groups_for_choose
      groups = mention_bot.chat.groups.order(:id)

      if groups.present?
        mention_bot.send_message(
          text: I18n.t('telegram.choose_group_for_add'),
          reply_markup: {
            inline_keyboard: groups.each_slice(2).map do |batch|
              batch.map do |group|
                { text: group.name, callback_data: "choose_group:#{group.name}" }
              end
            end
          }
        )
      else
        mention_bot.send_message(
          text: I18n.t('telegram.admin_group_not_exist')
        )
      end
    end

    def groups_handler(group)
      {
        text: I18n.t('telegram.group', name: group),
        parse_mode: 'Markdown',
        reply_markup: {
          inline_keyboard: [
            [
              { text: I18n.t('telegram.edit'), callback_data: "group:#{group}#edit" },
              { text: I18n.t('telegram.delete'), callback_data: "group:#{group}#delete" }
            ],
            [{ text: I18n.t('telegram.user_list'), callback_data: "group:#{group}#list" }],
            [{ text: I18n.t('telegram.delete_users'), callback_data: "group:#{group}#delete_users" }],
            [{ text: I18n.t('telegram.back'), callback_data: 'group:back' }]
          ]
        }
      }
    end

    def group_handler(command)
      return all_groups if command == 'back'

      group, actual_command = command.split('#')

      case actual_command
      when 'edit'
        add_target(group)
        mention_bot.add_context(:edit_group)

        { text: I18n.t('telegram.edit_group') }
      when 'delete'
        {
          text: I18n.t('telegram.confirm'),
          reply_markup: {
            inline_keyboard: [
              [
                { text: I18n.t('telegram.t_yes'), callback_data: "group:#{group}#destroy" },
                { text: I18n.t('telegram.t_no'), callback_data: "groups:#{group}" }
              ]
            ]
          }
        }
      when 'destroy'
        mention_bot.chat.groups.find_by!(name: group).destroy!

        { text: I18n.t('telegram.group_deleted', group_name: group), parse_mode: 'Markdown' }
      when 'list'
        group = mention_bot.chat.groups.includes(:users).find_by!(name: group)
        msg = group.users.map { |u| "- #{u.telegram_username}" }.join("\n")

        if msg.present?
          { text: msg }
        else
          { text: I18n.t('telegram.users_without_username') }
        end
      when 'delete_users'
        group = mention_bot.chat.groups.includes(:users).find_by!(name: group)
        users = group.users

        if users.present?
          {
            text: I18n.t('telegram.users_for_delete'),
            reply_markup: {
              inline_keyboard: group.users.map do |u|
                [{ text: u.telegram_username, callback_data: "user_group:#{group.name};#{u.id}#destroy" }]
              end.concat([[{ text: I18n.t('telegram.back'), callback_data: "groups:#{group.name}" }]])
            }
          }
        else
          { text: I18n.t('telegram.users_without_username') }
        end
      end
    rescue ActiveRecord::RecordNotFound => e
      mention_bot.send_message(text: I18n.t('telegram.group_not_found'))
    rescue ActiveRecord::RecordInvalid => e
      mention_bot.send_message(text: e.record.errors.full_messages.join("\n"))
    end

    def choose_group_handler(group)
      add_target(group)
      mention_bot.add_context(:add_clients)

      {
        text: I18n.t('telegram.format_for_add', group_name: group),
        parse_mode: 'Markdown'
      }
    end

    def user_group_handler(command)
      user_group, actual_command = command.split('#')
      group_name, user = user_group.split(';')

      group = ::Group.where(chat: mention_bot.chat).find_by!(name: group_name)

      case actual_command
      when 'destroy'
        group.user_groups.where(user_id: user).destroy_all

        group_handler("#{group_name}#delete_users")
      end
    rescue ActiveRecord::RecordNotFound => e
      mention_bot.send_message(text: I18n.t('telegram.user_in_group_not_found'))
    rescue ActiveRecord::RecordInvalid => e
      mention_bot.send_message(text: e.record.errors.full_messages.join("\n"))
    end
  end
end
