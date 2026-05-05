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
# You should have received a copy of the GNU General Public License along with Redmine DMSF FTS Bridge plugin. If not,
# see <https://www.gnu.org/licenses/>.

module RedmineDmsfFtsBridge
  module FullTextSearch
    class Setup
      def self.initialize_integration
        load_mapper
        register_resolver
        register_type
        extend_model
        attach_mapper
      end

      private

      def self.load_mapper
        require_relative 'dmsf_file_revision_mapper'
      end

      def self.register_resolver
        ::FullTextSearch.resolver.register(
          DmsfFileRevision,
          RedmineDmsfFtsBridge::DmsfFileRevisionMapper
        )
      end

      def self.register_type
        ::FullTextSearch::Type.dmsf_file_revision
      end

      def self.extend_model
        require_relative 'dmsf_file_revision_extension'
        DmsfFileRevision.include(RedmineDmsfFtsBridge::DmsfFileRevisionExtension)
      end

      def self.attach_mapper
        RedmineDmsfFtsBridge::DmsfFileRevisionMapper.attach(DmsfFileRevision)
      end
    end

    # Main setup method called during plugin initialization
    def self.setup
      Setup.initialize_integration
    rescue StandardError => e
      Rails.logger.error("Failed to initialize RedmineDmsfFtsBridge: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
    end
  end
end
