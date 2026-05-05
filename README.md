# DMSF Full Text Search Bridge Plugin

## Overview

This plugin provides integration between the Redmine DMSF (Document Management System Features) plugin and the Full Text Search plugin, allowing DMSF documents to be searchable using the Full Text Search functionality.

## Features

- **Automatic Indexing**: DMSF file revisions are automatically indexed when created or updated
- **Text Extraction**: Supports text extraction from various file formats using ChupaText
- **ActiveStorage Integration**: Full support for ActiveStorage-managed files
- **Asynchronous Processing**: Uses background jobs for efficient indexing
- **Synchronization**: Supports `rake full_text_search:synchronize` for batch re-indexing

## Requirements

- Redmine 6.1.0 or higher
- redmine_dmsf plugin
- full_text_search plugin
- ChupaText (for text extraction)

## Installation

1. Clone this plugin into the `plugins` directory of your Redmine installation:
   ```bash
   cd plugins
   git clone https://github.com/redmine-plugins/redmine_dmfs_fts_bridge.git
   cd ..
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Run migrations (if any):
   ```bash
   rails redmine:plugins:migrate
   ```

4. Restart Redmine

5. (Optional) Re-index existing documents:
   ```bash
   rake full_text_search:synchronize
   ```

## How It Works

### Initialization

When Redmine starts with both DMSF and Full Text Search plugins enabled, this bridge:

1. Registers the `DmsfFileRevision` mapper with the Full Text Search resolver
2. Creates the `DmsfFileRevision` type in the FTS database
3. Extends the `DmsfFileRevision` model with indexing callbacks

### Indexing Flow

```
DmsfFileRevision.save (create/update)
  ↓
after_commit callback
  ↓
FullTextSearch::UpsertTargetJob queued
  ↓
Text extracted from file (ActiveStorage)
  ↓
fts_target created/updated with searchable content
```

### Search Flow

```
User searches via FTS
  ↓
PGroonga searches index
  ↓
Results mapped via DmsfFileRevisionMapper
  ↓
Links to DMSF documents displayed
```

## Configuration

The plugin works out-of-the-box with default settings. For advanced configuration, see the DMSF and Full Text Search plugin documentation.

## Troubleshooting

### Bridge not initializing

Check the Rails log for initialization errors:
```bash
tail -f log/production.log
```

Ensure both DMSF and Full Text Search plugins are properly installed and enabled.

### Text extraction not working

1. Verify ChupaText is installed: `chupa-text --version`
2. Check file permissions on the storage directory
3. Monitor the Rails log for extraction errors

### Missing search results

Run the synchronization task to re-index documents:
```bash
rake full_text_search:synchronize
```

## License

GNU General Public License v3.0

## Contributing

Contributions are welcome. Please submit pull requests or issues to the project repository.
