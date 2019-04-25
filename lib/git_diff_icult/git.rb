module GitDiffIcult
  class Git
    def self.get_diff
      Dir.chdir(Rails.root) do
        status = `git diff`
      end
    end

    def self.has_diff?
      Dir.chdir(Rails.root) do
        status = `git diff`
        !status.blank?
      end
    end

    def self.get_status
      Dir.chdir(Rails.root) do
        status = `git status`
      end
    end

    def self.last_commit
      Dir.chdir(Rails.root) do
        last_commit = `git show`
      end
    end

    def self.get_each_left(status)
      s = status.split "diff --git"
      lefts = {}
      files = s.drop 1
      line_numbers = files.first.split("\n")[4].split
      files.each do |file|
        if line_numbers.size == 1
          line_numbers.push " "
        end
        start_line = line_numbers.second.split(",").first.to_i.abs
        line_current_count = 0
        file_name = file.split("\n").first.split(" ").first.split("a/").second
        file_content = ""
        file.split("\n").each_with_index do |line, index|
          if index >= 5
            if line.first != "+"
              ln = start_line + line_current_count
              file_content += ln.to_s + "| " + line + "\n"
              line_current_count += 1
            else
              # file_content += "\n"
            end
          end
        end
        lefts[file_name] = file_content.chomp "\n"
      end
      lefts
    end

    def self.get_each_right(status)
      s = status.split "diff --git"
      rights = {}
      files = s.drop 1
      files.each do |file|
        line_changes = get_line_numbers(file)
        line_changes.each do |line_numbers|
          start_line = line_numbers.split.second.split(",").first.to_i.abs
          end_line = line_numbers.split.second.split(",").second.to_i.abs
          line_current_count = 0
          file_name = file.split("\n").first.split(" ").first.split("a/").second
          file_content = ""
          lines = file.split("\n")
          while line_current_count <= start_line + end_line
            line_current_count += 1
          end
          line_current_count = 0
          file.split("\n").each_with_index do |line, index|
            if index >= 5
              if line.first != "-"
                ln = start_line + line_current_count
                file_content += ln.to_s + "| " + line + "\n"
                line_current_count += 1
              else

              end
            elsif line_current_count >= end_line
              break
            end
          end
          rights[file_name] = file_content.chomp "\n"
        end
      end
      rights
    end


    def self.get_last_left(diff)
      filenames = get_file_names(get_last_commit_hash)
      files = get_most_of_each_file(diff, filenames)
      ones = {}
      files.each_with_index do |file, i|
        file_content = ""
        lines = file.split("\n").drop(4)
        start_line = 0
        end_line = 0
        current_line_index = 0
        line_number = start_line + current_line_index
        lines.each do |line|
          if !line.match?(/@@ ([-]\d+,\d+\s[+]\d+,\d+) @@/)
            if line.first != "+"
              line.slice!(0)
              file_content += line + "\n"
              line_number += 1
            elsif line.first == "+"
            end
          else
            current_line_index = 0
            numbers = line.scan(/@@ ([-]\d+,\d+\s[+]\d+,\d+) @@/).map(&:join)
            # If left of right
            start_line = numbers.first.split(" ").first.split(",").first.to_i.abs
            line_number = start_line + current_line_index
            file_content += "\n"
          end
        end
        ones[filenames[i]] = file_content.chomp "\n"
      end
      ones
    end

    def self.get_last_right(diff)
      filenames = get_file_names(get_last_commit_hash)
      files = get_most_of_each_file(diff, filenames)
      ones = {}
      files.each_with_index do |file, i|
        file_content = ""
        lines = file.split("\n").drop(4)
        start_line = 0
        end_line = 0
        current_line_index = 0
        line_number = start_line + current_line_index
        lines.each do |line|
          if !line.match?(/@@ ([-]\d+,\d+\s[+]\d+,\d+) @@/)
            if line.first != "+"
            elsif line.first == "+"
              line.slice!(0)
              file_content += line + "\n"
            end
          else
            current_line_index = 0
            numbers = line.scan(/@@ ([-]\d+,\d+\s[+]\d+,\d+) @@/).map(&:join)
            # If left of right
            start_line = numbers.first.split(" ").first.split(",").first.to_i.abs
            line_number = start_line + current_line_index
            file_content += "\n"
          end
        end
        ones[filenames[i]] = file_content.chomp "\n"
      end
      ones
    end


    def self.get_last_commit_changes(diff)
      s = diff.split "diff --git"
      changes = {}
      files = s.drop 1
      files.each do |file|
        line_numbers = file.split("\n")[4].split
        if line_numbers.size == 1
          line_numbers.push " "
        end
        line_current_count = 0
        file_name = file.split("\n").first.split(" ").first.split("a/").second
        file_content = ""
        file.split("\n").each_with_index do |line, index|
          if index >= 5
              file_content +=  line + "\n"
              line_current_count += 1
          end
        end
        changes[file_name] = file_content.chomp "\n"
      end
      changes
    end

    def self.get_last_diff
      Dir.chdir(Rails.root) do
        last_diff  = `git diff -M HEAD~1`
      end
    end

    def self.parse_into_one(diff)
      get_nonsplit_diff(diff)
    end

    def self.get_nonsplit_diff(diff)
    filenames = get_file_names(get_last_commit_hash)
      files = get_most_of_each_file(diff, filenames)
      ones = {}
      files.each_with_index do |file, i|
        file_content = ""
        lines = file.split("\n").drop(4)
        start_line = 0
        end_line = 0
        current_line_index = 0
        line_number = start_line + current_line_index
        lines.each do |line|
          if !line.match?(/@@ ([-]\d+,\d+\s[+]\d+,\d+) @@/)
            if line.first != "+"
              file_content += line + "\n"
              line_number += 1
            elsif line.first == "+"
              file_content += line + "\n"
            end
          else
            current_line_index = 0
            numbers = line.scan(/@@ ([-]\d+,\d+\s[+]\d+,\d+) @@/).map(&:join)
            # If left of right
            start_line = numbers.first.split(" ").first.split(",").first.to_i.abs
            line_number = start_line + current_line_index
            file_content += "\n"
          end
        end
        ones[filenames[i]] = file_content.chomp "\n"
      end
      ones
    end


    def self.get_file_names(commit)
      Dir.chdir(Rails.root) do
        filenames = `git diff-tree --no-commit-id --name-only -r #{commit}`
        if commit.blank?
          filenames = `git diff --name-only`
        end
        filenames.split("\n")
      end
    end

    def self.last_to_html(left_hash, right_hash)
      html_output = ""
      left_hash.keys.each do |file|
        html_output += Diffy::Diff.new(left_hash[file], right_hash[file], :include_plus_and_minus_in_html => true).to_s(:html)
      end
      html_output.html_safe
    end

    def self.get_last_commit_hash
      Dir.chdir(Rails.root) do
        log = `git log -1 --oneline`
        log.split.first
      end
    end

    def self.get_second_to_last_commit_hash
      Dir.chdir(Rails.root) do
        log = `git log -2 --oneline`
        log.split("\n").last.split.first
      end
    end

    def self.show_file_at_commit(file, commit)
      Dir.chdir(Rails.root) do
        show = `git show #{commit}:#{file}`
      end
    end

    def self.get_line_numbers(file)
      line_changes = file.scan(/@@ ([-]\d+,\d+\s[+]\d+,\d+) @@/).map(&:join)
    end

    def self.get_each_file(diff, filenames)
      splitted = diff.split(filenames.first)
      tt = splitted.split("diff --git a/" + filenames.second)
      tt.first
      tt.last.split(/@@ ([-]\d+,\d+\s[+]\d+,\d+) @@/).map(&:join)
    end

    def self.file_keys(diff)
      lines = diff.split("\n")
      indexes = []
      lines.index { |line| line.match?(/@@ ([-]\d+,\d+\s[+]\d+,\d+) @@/) }
      lines.each do |line|
        if line.match?(/@@ ([-]\d+,\d+\s[+]\d+,\d+) @@/)
          indexes.push(line)
        end
      end
      lines.uniq
      # diff.scan(/@@ (\w+\s+\w*)/).uniq.flatten
      # keys.map(&:join)
    end

    def self.get_most_of_each_file(diff, filenames)
      files = []
      lines = diff.split("\n")
      last_index = 0
      filenames.count.times do |i|
        file = filenames[i]
      	content = ""
      	last_index.upto(lines.count - 1) do |index|
      		line = lines[index]
      		if !match_other_files(line, file, filenames)
      			content += line + "\n"
      		else
      			last_index = index
      			break
      		end
      	end
  			files.push content
      end
      files
    end

    def self.match_other_files(line, file, filenames)
    	filenames.each do |other_file|
    		if file != other_file
    			if line.include?('diff --git a/' + other_file + ' b/' + other_file)
    				return true
    			end
    		end
    	end
    	false
    end

    def self.left_again_for_real(diff)
      filenames = get_file_names("")
      files = get_most_of_each_file(diff, filenames)
      rights = {}
      files.each_with_index do |file, i|
        file_content = ""
        lines = file.split("\n").drop(4)
        start_line = 0
        end_line = 0
        current_line_index = 0
        line_number = start_line + current_line_index
        lines.each do |line|
          if !line.match?(/@@ ([-]\d+,\d+\s[+]\d+,\d+) @@/)
            if line.first != "+"
              file_content += "#{line_number}| " + line + "\n"
              line_number += 1
            elsif line.first == "+"
              # file_content += "|\n"
            end
          else
            current_line_index = 0
            numbers = line.scan(/@@ ([-]\d+,\d+\s[+]\d+,\d+) @@/).map(&:join)
            # If left of right
            start_line = numbers.first.split(" ").first.split(",").first.to_i.abs
            line_number = start_line + current_line_index
            file_content += "\n"
          end
        end
        rights[filenames[i]] = file_content.chomp "\n"
      end
      rights
    end

    def self.right_again_for_real(diff)
      filenames = get_file_names("")
      files = get_most_of_each_file(diff, filenames)
      rights = {}
      files.each_with_index do |file, i|
        file_content = ""
        lines = file.split("\n").drop(4)
        start_line = 0
        end_line = 0
        current_line_index = 0
        line_number = start_line + current_line_index
        lines.each do |line|
          if !line.match?(/@@ ([-]\d+,\d+\s[+]\d+,\d+) @@/)
            if line.first != "-"
              file_content += "#{line_number}| " + line + "\n"
              line_number += 1
            end
          else
            current_line_index = 0
            numbers = line.scan(/@@ ([-]\d+,\d+\s[+]\d+,\d+) @@/).map(&:join)
            # If left of right
            start_line = numbers.first.split(" ").second.split(",").first.to_i.abs
            line_number = start_line + current_line_index
            file_content += "\n"
          end
        end
        rights[filenames[i]] = file_content.chomp "\n"
      end
      rights
    end
  end
end
