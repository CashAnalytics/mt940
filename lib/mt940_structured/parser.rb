
module MT940Structured
  class Parser
    def self.parse_mt940(path, join_lines_by = ' ')
      file_content = FileContent.new(readstreamfile(StringIO.new(force_file_encoding(path))), join_lines_by)
      grouped_lines = file_content.group_lines
      file_content.get_header.parser.transform(grouped_lines)
    end

    def self.parse_mt940_temp_file(stream, join_lines_by = ' ')
      if stream.instance_of?(String)
        file_content = FileContent.new(readstreamfile(StringIO.new(force_string_encoding(stream))), join_lines_by)
      else
        file_content = FileContent.new(readstreamfile(StringIO.new(force_file_encoding(stream.tempfile.open))), join_lines_by)
      end
      grouped_lines = file_content.group_lines
      file_content.get_header.parser.transform(grouped_lines)
    end


private
    def self.readstreamfile(stringio)
      stringio.readlines.map do |line|
        line.sub!("\xEF\xBB\xBF", '')
        line
          .gsub(/\u001A/, '') # remove eof chars in the middle of the string... yes it happens :-(
      end
    end
    def self.bank_name(path, join_lines_by = ' ')
      file_content = FileContent.new(readfile(path), join_lines_by)
      file_content.get_header.parser.bank
    end

    def self.readfile(path)
      File.open(path, 'r:bom|utf-8').readlines.map do |line|

        line
          .gsub(/\u001A/, '') # remove eof chars in the middle of the string... yes it happens :-(
      end
    end

    def self.source_encode(string)
      if string.encoding.to_s=='UTF-8'
        return 'UTF-8'
      end
      return 'binary'
    end

    def self.force_file_encoding(file)
      if file.is_a?(StringIO)
        txt = file.read
      elsif file.respond_to?(:path)
        txt = File.read(file.path)
      elsif file.is_a?(String)
        txt = File.read(file)
      else
        raise 'Error reading file'
      end
      force_string_encoding(txt)
    end

    def self.force_string_encoding(txt)
      chardet = CharDet.detect(txt)
      txt = txt.force_encoding('iso-8859-1').encode('utf-8') unless chardet['encoding'] == 'utf-8'
      txt.scrub!
    end
  end
end
