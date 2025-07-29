# Matt Wilson - Portfolio Website

Static HTML/CSS portfolio built with modern deployment practices. Features my
professional experience, major projects, and technical background.

🌐 **Live Site**: [mattwilson.io](https://mattwilson.io)

## Repository Structure

```
matt-wilson-io/
├── .github/workflows/     # Automated deployment
├── infrastructure/        # Terraform configuration  
├── scripts/              # Server setup automation
└── static/               # Website content
    ├── index.html
    ├── styles.css
    └── assets/
```

## Technology Stack

- **Frontend**: HTML/CSS static site
- **Infrastructure**: Terraform + DigitalOcean
- **Deployment**: GitHub Actions with automated SSL
- **Web Server**: Nginx

## Local Development

```bash
git clone https://github.com/Mattwwilson34/matt-wilson-io.git
cd matt-wilson-io/static
go run .
# Visit http://localhost:8080
```

## Deployment

The site automatically deploys when changes are pushed to the `static/` directory. Infrastructure is managed with Terraform for reproducible deployments.

