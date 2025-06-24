# Resilient URL Scanner 🔍

A high-performance, crash-resistant URL scanner designed for large-scale web reconnaissance and penetration testing. Built to handle millions of URLs with automatic resume capabilities and progress tracking.

## 🚀 Features

- **Massive Scale**: Efficiently scan millions of URLs
- **Crash Resistant**: Automatic resume functionality - survives server crashes, network issues, and interruptions
- **Progress Tracking**: Real-time monitoring with chunk-based processing
- **High Performance**: Multi-threaded scanning with configurable concurrency
- **Memory Efficient**: Processes URLs in chunks to avoid memory exhaustion
- **Detailed Logging**: Comprehensive error logging and result tracking
- **Cloud Optimized**: Designed for VPS/cloud environments (tested on Digital Ocean)

## 📋 Prerequisites

- Ubuntu/Debian Linux system
- Go 1.19+ (for httpx installation)
- At least 1GB RAM recommended
- Stable internet connection

## 💰 Recommended Hosting

**Digital Ocean** (Recommended for this tool):
- **[Get $200 in free credits](https://m.do.co/c/e22bbff5f6f1)** for new accounts
- Excellent network performance for URL scanning
- Simple pricing with no surprise charges
- Tested and optimized for this scanner

**Recommended droplet sizes**:
- **$6/month**: 1 CPU, 1-2GB RAM (good for up to 1M URLs)
- **$12/month**: 2 CPU, 2GB RAM (optimal for 5M+ URLs)
- **$24/month**: 4 CPU, 8GB RAM (fastest processing)

## 🛠️ Installation

### Quick Setup Script

```bash
# Clone the repository
git clone https://github.com/random-robbie/resilient-url-scanner.git
cd resilient-url-scanner

# Run the setup script
chmod +x setup.sh
./setup.sh
```

### Manual Installation

```bash
# Update system
apt update && apt upgrade -y

# Install dependencies
apt install -y golang-go screen htop wget curl

# Install httpx
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

# Add Go bin to PATH
echo 'export PATH=$PATH:/root/go/bin' >> ~/.bashrc
source ~/.bashrc

# Verify installation
httpx -version
```

## 📊 Usage

### Basic Usage

1. **Prepare your URL list**:
   ```bash
   # Place your URLs in urls.txt (one per line)
   echo "example.com" > urls.txt
   echo "test.com" >> urls.txt
   ```

2. **Start the scanner**:
   ```bash
   # Run in screen session (recommended)
   screen -S scanner
   ./scan.sh
   
   # Detach from screen: Ctrl+A then D
   # Reattach later: screen -r scanner
   ```

3. **Monitor progress**:
   ```bash
   # In a new terminal
   ./monitor.sh
   
   # Or quick status check
   ./status.sh
   ```

### Advanced Configuration

Edit the configuration variables in `scan.sh`:

```bash
# Chunk size (URLs per chunk)
CHUNK_SIZE=5000

# Concurrent threads
THREADS=80

# Request timeout (seconds)
TIMEOUT=8
```

## 📁 Directory Structure

```
resilient-url-scanner/
├── scan.sh           # Main scanner script
├── monitor.sh        # Progress monitoring script
├── status.sh         # Quick status checker
├── setup.sh          # Installation script
├── urls.txt          # Input URL list
├── completed/        # Tracks completed chunks
├── results/          # Scan results
│   └── live_urls.txt # Live URLs found
├── logs/             # Error logs
│   └── errors.log    # Scanning errors
└── chunk_*           # URL chunks (auto-generated)
```

## 🔧 Configuration Options

### Scanner Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `CHUNK_SIZE` | 5000 | URLs processed per chunk |
| `THREADS` | 80 | Concurrent scanning threads |
| `TIMEOUT` | 8 | HTTP request timeout (seconds) |
| `RETRIES` | 1 | Number of retry attempts |

### httpx Parameters

The scanner uses optimized httpx settings:
- Status code detection
- Silent output (reduced noise)
- No color output (log-friendly)
- Automatic retries
- Custom timeout values

## 📈 Performance Benchmarks

| URLs | Server Specs | Duration | Success Rate |
|------|-------------|----------|--------------|
| 100K | 1 CPU, 1GB RAM | ~2 hours | 15-25% |
| 1M | 1 CPU, 2GB RAM | ~18 hours | 15-25% |
| 6M | 2 CPU, 4GB RAM | ~2-3 days | 15-25% |

*Results vary based on target responsiveness and network conditions*

## 🚨 Resume After Interruption

The scanner automatically resumes from where it left off:

```bash
# Simply run the script again
./scan.sh

# It will skip completed chunks and continue
```

## 📊 Monitoring and Status

### Real-time Monitoring

```bash
# Continuous monitoring dashboard
./monitor.sh
```

### Quick Status Check

```bash
# Current progress summary
./status.sh

# Manual status check
echo "Progress: $(ls completed/ 2>/dev/null | wc -l)/$(ls chunk_* 2>/dev/null | wc -l) chunks"
echo "Live URLs: $(wc -l < results/live_urls.txt 2>/dev/null || echo 0)"
```

## 📝 Output Format

Results are saved in `results/live_urls.txt` with the format:
```
https://example.com [200]
https://test.com [301]
https://site.org [403]
```

## 🐛 Troubleshooting

### Common Issues

1. **httpx not found**:
   ```bash
   export PATH=$PATH:/root/go/bin
   # Or use full path: /root/go/bin/httpx
   ```

2. **Permission denied**:
   ```bash
   chmod +x scan.sh monitor.sh status.sh
   ```

3. **Out of memory**:
   - Reduce `CHUNK_SIZE` to 1000-2000
   - Reduce `THREADS` to 50 or lower

4. **Network timeouts**:
   - Increase `TIMEOUT` to 15-20 seconds
   - Reduce `THREADS` for stability

## 🔐 Security Considerations

- **Responsible Use**: Only scan domains you own or have explicit permission to test
- **Rate Limiting**: Built-in threading limits to avoid overwhelming targets
- **Legal Compliance**: Ensure compliance with local laws and regulations
- **Ethical Guidelines**: Follow responsible disclosure practices

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Commit changes: `git commit -am 'Add feature'`
4. Push to branch: `git push origin feature-name`
5. Submit a Pull Request

### Development Guidelines

- Test with small URL sets first
- Document any new features
- Follow existing code style
- Include error handling
- Update README for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This tool is intended for authorized security testing and research purposes only. Users are responsible for ensuring they have proper authorization before scanning any domains or networks. The authors are not responsible for any misuse or damage caused by this tool.

## 🙏 Acknowledgments

- [ProjectDiscovery](https://github.com/projectdiscovery) for the excellent httpx tool
- The penetration testing community for inspiration and feedback
- [Digital Ocean](https://m.do.co/c/e22bbff5f6f1) for reliable and affordable cloud infrastructure (referral link - helps support this project!)

*Note: The Digital Ocean link above is a referral link that provides $200 in free credits for new users and helps support the development of this project.*

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/random-robbie/resilient-url-scanner/issues)
- **Discussions**: [GitHub Discussions](https://github.com/random-robbie/resilient-url-scanner/discussions)
- **Security**: Report security issues privately to [security email]

---

**Happy Hunting!** 🎯

*Built with ❤️ for the cybersecurity community*