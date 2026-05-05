# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class RedmineDmsfFtsBridgeTest < ActiveSupport::TestCase
  fixtures :projects, :users, :members, :member_roles, :roles, :enabled_modules

  def setup
    # Ensure the integration is initialized
    RedmineDmsfFtsBridge::FullTextSearch.setup
  end

  def test_registration
    assert_equal RedmineDmsfFtsBridge::DmsfFileRevisionMapper,
                 FullTextSearch.resolver.resolve(DmsfFileRevision)
    assert_not_nil FullTextSearch::Type.find_by(name: 'DmsfFileRevision')
  end

  def test_upsert_fts_target
    project = Project.find(1)
    user = User.find(1)

    # Create DMSF file
    dmsf_file = DmsfFile.new(project: project)
    dmsf_file.save!

    # Create DMSF file revision
    revision = DmsfFileRevision.new(
      dmsf_file: dmsf_file,
      user: user,
      name: 'test_file.txt',
      title: 'test_file',
      major_version: 0,
      minor_version: 1,
      patch_version: 0,
      comment: 'Initial version'
    )
    revision.save!

    # Check if target is created
    target = FullTextSearch::Target.find_by(
      source_id: revision.id,
      source_type_id: FullTextSearch::Type.dmsf_file_revision.id
    )

    assert_not_nil target, "FTS target should be created for DmsfFileRevision"
    assert_equal "test_file.txt (v0.1.0)", target.title
    assert_includes target.content, "Initial version"
    assert_equal project.id, target.project_id
  end

  def test_destroy_fts_target
    project = Project.find(1)
    user = User.find(1)

    dmsf_file = DmsfFile.new(project: project)
    dmsf_file.save!

    revision = DmsfFileRevision.new(
      dmsf_file: dmsf_file,
      user: user,
      name: 'to_be_deleted.txt',
      title: 'to_be_deleted',
      major_version: 1,
      minor_version: 0,
      patch_version: 0
    )
    revision.save!

    target = FullTextSearch::Target.find_by(source_id: revision.id, source_type_id: FullTextSearch::Type.dmsf_file_revision.id)
    assert_not_nil target

    revision.destroy!

    assert_nil FullTextSearch::Target.find_by(id: target.id), "FTS target should be deleted when revision is destroyed"
  end
end
