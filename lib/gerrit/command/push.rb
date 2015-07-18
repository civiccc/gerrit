module Gerrit::Command
  # Push one or more commits for review.
  class Push < Base
    def execute
      # If an explicit ref is given, skip a bunch of the questions
      if commit_hash?(arguments[1]) || arguments[1] == 'HEAD'
        ref = arguments[1]
        reviewer_args = arguments[2..-1] || []
        target_branch = 'master'
        type = 'publish'
        topic = nil
      else
        ref = 'HEAD'
        reviewer_args = arguments[1..-1] || []
        target_branch = ask_target_branch
        type = ask_review_type
        topic = ask_topic
      end

      reviewers = extract_reviewers(reviewer_args)

      push_changes(ref, reviewers, target_branch, type, topic)
    end

    private

    def push_changes(ref, reviewers, target_branch, type, topic)
      command = %W[git push #{repo.remote_url}]

      if reviewers.any?
        reviewer_flags = reviewers.map { |reviewer| "--reviewer=#{reviewer}" }
        command += ['--receive-pack', "git receive-pack #{reviewer_flags.join(' ')}"]
      end

      destination_ref = "refs/#{type}/#{target_branch}"
      destination_ref += "/#{topic}" if topic
      command += ["#{ref}:#{destination_ref}"]

      execute(command)
    end

    def extract_reviewers(reviewer_args)
      if reviewer_args.empty?
        reviewer_args = ui.ask('Enter users/groups you would like to review your changes')
                          .argument(:required)
                          .read_string
                          .split(/\s*,\s*/)
      end

      return [] if reviewer_args.empty?

      ui.spinner('Finding matching users/groups...') do
        extract_users(reviewer_args)
      end
    end

    def extract_users(reviewer_args)
      usernames = []
      groups = client.groups
      users = client.users

      reviewer_args.each do |arg|
        users_or_groups = arg.split(/\s*,\s*|\s+/)

        users_or_groups.each do |user_or_group|
          usernames += users_from_pattern(users, groups, user_or_group)
        end
      end

      usernames.uniq.sort
    end

    def users_from_pattern(users, groups, pattern)
      group_users = users_from_group(groups, pattern)

      # Don't scan users since we already matched a group
      return group_users if group_users.any?

      users.grep(/#{pattern}/i)
    end

    def users_from_group(groups, group)
      matching_groups = groups.grep(/#{group}/i)

      map_in_parallel(matching_groups) do |match|
        client.group_members(match).map { |user| user[:username] }
      end.flatten.uniq
    end

    def ask_target_branch
      target = ui.ask('Target branch (default master)')
                 .modify(:trim)
                 .read_string

      target.empty? ? 'master' : target
    end

    def ask_review_type
      draft = ui.ask('Are you pushing this as a draft? (y/n) [n]')
                .argument(:required)
                .default('n')
                .modify(:downcase)
                .validate(/^y|n/)
                .read_string

      draft == 'y' ? 'draft' : 'publish'
    end

    def ask_topic
      topic = ui.ask('Topic name (optional; enter * to autofill with your current branch:')
                .argument(:optional)
                .read_string

      topic = repo.branch('HEAD') if topic == '*'
      topic.strip.empty? ? nil : topic
    end

  end
end
