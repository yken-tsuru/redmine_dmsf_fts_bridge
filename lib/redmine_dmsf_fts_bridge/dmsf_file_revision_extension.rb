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
  module DmsfFileRevisionExtension
    extend ActiveSupport::Concern

    def latest_revision?
      self == dmsf_file.last_revision
    end

    private

    def fts_available?
      defined?(::FullTextSearch)
    end
  end
end
