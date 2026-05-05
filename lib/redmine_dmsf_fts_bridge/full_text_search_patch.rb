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

# Patch for Full Text Search plugin to support DmsfFileRevision
module RedmineDmsfFtsBridge
  module FullTextSearchPatch
    def self.apply_patches
      # Patch the FullTextSearch::Type class to add dmsf_file_revision type
      patch_fts_type
      
      # Patch the FullTextSearch::Target class if needed
      patch_fts_target
    end

    def self.patch_fts_type
      ::FullTextSearch::Type.class_eval do
        def self.dmsf_file_revision
          find_or_create_by!(name: 'DmsfFileRevision')
        end
      end
    end

    def self.patch_fts_target
      # Add any necessary patches to FullTextSearch::Target here
      # For now, this is left as a hook for future extensions
    end
  end
end
# Apply patches when this module is loaded
RedmineDmsfFtsBridge::FullTextSearchPatch.apply_patches
