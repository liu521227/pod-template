require 'xcodeproj'

module Pod

  class ProjectManipulator
    attr_reader :configurator, :xcodeproj_path, :bundleId
    def initialize(options)
      @xcodeproj_path = options.fetch(:xcodeproj_path)
      @configurator = options.fetch(:configurator)
      @bundleId = options.fetch(:bundleId)
    end

    def run
      @string_replacements = {
        "org.cocoapods.demo.PROJECT" => @configurator.bundleId,
        "PROJECT" => @configurator.pod_name,
      }
      replace_internal_project_settings

      @project = Xcodeproj::Project.open(@xcodeproj_path)
      # add_podspec_metadata
      # remove_demo_project if @remove_demo_target
      @project.save

      rename_files
      rename_project_folder
    end

    def project_folder
      File.dirname @xcodeproj_path
    end

    def rename_files
      # rename xcproject
      File.rename(project_folder + "/PROJECT.xcodeproj", project_folder + "/" +  @configurator.pod_name + ".xcodeproj")
    end

    def rename_project_folder
      if Dir.exist? project_folder + "/PROJECT"
        File.rename(project_folder + "/PROJECT", project_folder + "/" + @configurator.pod_name)
      end
    end

    def replace_internal_project_settings
      Dir.glob(project_folder + "/**/**/**/**").each do |name|
        next if Dir.exists? name
        text = File.read(name)

        for find, replace in @string_replacements
            text = text.gsub(find, replace)
        end

        File.open(name, "w") { |file| file.puts text }
      end
    end

  end

end
