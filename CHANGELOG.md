# Changelog

All notable changes to the Resilient URL Scanner will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-06-24

### Added
- Initial release of Resilient URL Scanner
- Chunk-based URL processing for memory efficiency
- Automatic resume functionality after crashes/interruptions
- Real-time monitoring dashboard with progress tracking
- Configurable threading and timeout settings
- Comprehensive error logging and result tracking
- Color-coded terminal output for better UX
- Progress percentage and ETA calculations
- Support for millions of URLs with stable performance
- Digital Ocean VPS optimization and setup guides

### Features
- **Core scanning**: httpx-based URL validation and HTTP status checking
- **Resilience**: Crash-resistant design with automatic state recovery
- **Monitoring**: Real-time progress dashboard and quick status checks
- **Scalability**: Handles 6M+ URLs efficiently with chunked processing
- **Configuration**: Adjustable chunk sizes, threading, and timeouts
- **Logging**: Detailed error logs and success tracking

### Scripts
- `setup.sh`: Automated installation and configuration
- `scan.sh`: Main scanning engine with resume capability
- `monitor.sh`: Real-time monitoring dashboard
- `status.sh`: Quick status and progress checker

### Documentation
- Comprehensive README with setup instructions
- Performance benchmarks and hardware recommendations
- Troubleshooting guide for common issues
- Contributing guidelines for open source development
- MIT License for community contributions

### Infrastructure
- Optimized for Digital Ocean VPS deployment
- Ubuntu/Debian support with dependency management
- Screen/tmux session management for background operation
- Directory structure for organized result storage

### Coming Soon
- [ ] JSON/CSV output formats
- [ ] Webhook notifications
- [ ] Custom headers and authentication
- [ ] Distributed scanning across multiple servers
- [ ] Web dashboard interface
- [ ] Docker containerization

---

## Versioning Notes

- **Major versions** (X.0.0): Breaking changes or major feature additions
- **Minor versions** (1.X.0): New features that are backward compatible
- **Patch versions** (1.0.X): Bug fixes and small improvements

## Support

For issues, feature requests, or contributions, please visit:
- [GitHub Issues](https://github.com/random-robbie/resilient-url-scanner/issues)
- [GitHub Discussions](https://github.com/random-robbie/resilient-url-scanner/discussions)