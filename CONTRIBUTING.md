# Contributing to Resilient URL Scanner

Thank you for your interest in contributing to the Resilient URL Scanner! We welcome contributions from the cybersecurity community.

## 🚀 Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR-USERNAME/resilient-url-scanner.git`
3. Create a feature branch: `git checkout -b feature-name`
4. Make your changes
5. Test thoroughly
6. Submit a Pull Request

## 🧪 Testing

Before submitting a PR:

1. Test with small URL sets (< 100 URLs) first
2. Verify resume functionality works after interruption
3. Check that monitoring scripts display correctly
4. Ensure error handling works properly

```bash
# Create a small test set
echo -e "google.com\nexample.com\ngithub.com" > test_urls.txt
cp test_urls.txt urls.txt

# Test the scanner
./scan.sh

# Test monitoring
./monitor.sh

# Test status
./status.sh
```

## 📝 Code Style

- Use clear, descriptive variable names
- Add comments for complex logic
- Follow existing script formatting
- Include error handling for edge cases
- Use colors in output for better UX

## 🔧 Development Guidelines

### Shell Scripts
- Use `#!/bin/bash` shebang
- Quote variables: `"$variable"`
- Check exit codes: `if [ $? -ne 0 ]; then`
- Use functions for repeated code
- Add help messages for user-facing scripts

### New Features
- Maintain backward compatibility
- Update README.md with new functionality
- Add configuration options when appropriate
- Consider impact on large-scale scans

## 🐛 Bug Reports

When reporting bugs, include:
- Operating system and version
- Error messages (full output)
- Steps to reproduce
- Expected vs actual behavior
- URL count and server specs

## 💡 Feature Requests

We welcome feature suggestions! Consider:
- Use case and benefit
- Impact on performance
- Compatibility with existing workflows
- Implementation complexity

## 🔐 Security

- Only test on domains you own or have permission to scan
- Include appropriate warnings in new features
- Don't hardcode credentials or sensitive data
- Follow responsible disclosure for any vulnerabilities

## 📚 Documentation

- Update README.md for new features
- Add inline comments for complex code
- Include usage examples
- Update troubleshooting section as needed

## 🏷️ Pull Request Guidelines

### PR Title Format
- `feat: add new monitoring feature`
- `fix: resolve chunk processing bug`
- `docs: update installation instructions`
- `perf: improve scanning performance`

### PR Description
Include:
- What changes were made
- Why the changes were needed
- Testing performed
- Any breaking changes

## 🎯 Areas for Contribution

We especially welcome contributions in:

- **Performance optimization**: Faster scanning algorithms
- **Monitoring improvements**: Better progress tracking
- **Output formats**: JSON, CSV, XML export options
- **Resume functionality**: More robust state management
- **Error handling**: Better failure recovery
- **Documentation**: Examples, tutorials, troubleshooting
- **Platform support**: Windows/macOS compatibility
- **Integration**: APIs, webhooks, notifications

## 📞 Getting Help

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and ideas
- **Code Review**: Tag maintainers for review

## 🌟 Recognition

Contributors will be acknowledged in:
- README.md contributors section
- Release notes for significant contributions
- Project documentation

## ⚖️ License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for helping make the Resilient URL Scanner better for the cybersecurity community! 🎯