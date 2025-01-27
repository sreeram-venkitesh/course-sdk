
class TesterDownloader
  def initialize(course:, testers_root_dir:)
    @course = course
    @testers_root_dir = testers_root_dir
  end

  def download_if_needed
    return tester_dir if File.exist?(tester_dir)

    compressed_file_path = File.join(@testers_root_dir, "#{@course.slug}.tar.gz")

    FileUtils.mkdir_p(@testers_root_dir)
    File.open(compressed_file_path, "wb") do |file|
      artifact_url = "https://github.com/#{tester_repository_name}/releases/download/#{latest_tester_version}/#{latest_tester_version}_linux_amd64.tar.gz"

      HTTParty.get(artifact_url, stream_body: true) do |fragment|
        file.write(fragment)
      end
    end

    FileUtils.mkdir_p(tester_dir)
    `tar xf #{compressed_file_path} -C #{tester_dir}`
    File.delete(compressed_file_path)

    tester_dir
  end

  def latest_tester_version
    @latest_tester_version ||= begin
      latest_release = HTTParty.get("https://api.github.com/repos/#{tester_repository_name}/releases/latest")
      latest_release["tag_name"]
    end
  end

  def tester_dir
    File.join(@testers_root_dir, @course.slug)
  end

  def tester_repository_name
    "codecrafters-io/#{@course.slug}-tester"
  end
end