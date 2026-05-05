# frozen_string_literal: true

# Redmine plugin for DMSF and Full Text Search bridge
#
# This file is part of Redmine DMSF Full Text Search Bridge plugin.
#
# Redmine DMSF FTS Bridge is free software: you can redistribute it and/or modify it under the terms of the GNU General
# Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# Redmine DMSF FTS Bridge is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
# the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along with Redmine DMSF Bridge plugin. If not,
# see <https://www.gnu.org/licenses/>.

module RedmineDmsfFtsBridge
  class DmsfFileRevisionMapper < ::FullTextSearch::Mapper
    class << self
      def redmine_mapper_class
        RedmineDmsfFileRevisionMapper
      end

      def fts_mapper_class
        FtsDmsfFileRevisionMapper
      end
    end
  end

  class RedmineDmsfFileRevisionMapper < ::FullTextSearch::RedmineMapper
    class << self
      def with_project(redmine_class)
        redmine_class.joins(dmsf_file: :project)
      end
    end

    def upsert_fts_target(options = {})
      fts_target = find_fts_target
      fts_target.source_id = @record.id
      fts_target.source_type_id = ::FullTextSearch::Type[@record.class].id
      fts_target.project_id = @record.dmsf_file.project_id
      fts_target.title = "#{@record.dmsf_file.name} (v#{@record.version})"
      fts_target.content = build_description
      fts_target.last_modified_at = @record.updated_at
      fts_target.registered_at = @record.created_at

      tag_ids = []
      tag_ids.concat(extract_tag_ids_from_path(@record.dmsf_file.name))
      fts_target.tag_ids = tag_ids

      prepare_text_extraction(fts_target)
      fts_target.save!
      extract_content(fts_target, options)
    end

    def extract_text
      return unless @record.shared_file&.attached?

      fts_target = find_fts_target
      return unless fts_target.persisted?

      content = nil
      @record.shared_file.open do |tempfile|
        path = @record.dmsf_file.name
        content_type = @record.content_type
        metadata = [
          ['path', path],
          ['content-type', content_type]
        ]
        content = run_text_extractor(fts_target, metadata) do |extractor|
          extractor.extract(Pathname(tempfile.path), nil, content_type)
        end
      end

      set_extracted_content(fts_target,
                            content,
                            [build_description])
      fts_target.save!
    end

    private

    def build_description
      parts = []
      parts << "File: #{@record.dmsf_file.name}"
      parts << "Version: #{@record.version}"
      parts << @record.dmsf_file.description if @record.dmsf_file.description.present?
      parts << "Comment: #{@record.comment}" if @record.comment.present?
      parts.join("\n")
    end
  end

  class FtsDmsfFileRevisionMapper < ::FullTextSearch::FtsMapper
    def type
      'dmsf-file-revision'
    end

    def title
      @record.title.to_s
    end

    def url
      {
        controller: 'dmsf_files',
        action: 'show',
        id: redmine_record.dmsf_file_id,
        project_id: redmine_record.dmsf_file.project_id
      }
    end
  end
end
