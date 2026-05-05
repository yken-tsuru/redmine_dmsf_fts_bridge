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

require 'redmine'
require_relative 'lib/redmine_dmsf_fts_bridge/full_text_search'

Redmine::Plugin.register :redmine_dmsf_fts_bridge do
  name 'DMSF Full Text Search Bridge'
  url 'https://github.com/yken-tsuru/redmine_dmsf_fts_bridge'
  author 'Yken Tsuru'
  description 'Bridge plugin for integrating Redmine DMSF with Full Text Search plugin'
  version '0.1.0'

  requires_redmine version_or_higher: '6.1.0'
end

# Load the bridge integration
Rails.application.config.after_initialize do
  begin
    # Check if required plugins are available
    if Redmine::Plugin.find(:redmine_dmsf) && Redmine::Plugin.find(:full_text_search)
      require_relative 'lib/redmine_dmsf_fts_bridge/full_text_search_patch'
      RedmineDmsfFtsBridge::FullTextSearch.setup
      Rails.logger.info('DMSF Full Text Search Bridge initialized successfully')
    end
  rescue StandardError => e
    Rails.logger.error("Failed to initialize DMSF Full Text Search Bridge: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
  end
end
