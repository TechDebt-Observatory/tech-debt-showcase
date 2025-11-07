# Technical Debt Observatory

AI-assisted technical debt analysis of critical open source infrastructure.

## 🚀 Quick Start

This site is a static HTML showcase demonstrating automated code analysis using Claude (Anthropic AI).

### What's Included

- `index.html` - Landing page with value proposition
- `raw-code.html` - Shows original OpenSSL code
- `analysis.html` - Detailed technical debt breakdown
- `commented.html` - Fully commented code version
- `scale.html` - Vision for scaling the project

## 📦 Deployment to DigitalOcean

### Prerequisites

1. GitHub account
2. DigitalOcean account (free tier works)
3. Apple Hide My Email OR Formspree account

### Step 1: Set Up This Repository

Already done if you're reading this!

### Step 2: Update Contact Form

In BOTH `index.html` and `scale.html`, find this line:
```html
<form action="https://formspree.io/f/YOUR_FORM_ID" method="POST">
```

Replace `YOUR_FORM_ID` with your actual Formspree form ID:

#### Get Formspree ID:
1. Go to https://formspree.io
2. Sign up (free tier: 50 submissions/month)
3. Click "New Form"
4. Enter your Apple Hide My Email address
5. Copy the form ID (looks like `abcd1234`)
6. Replace `YOUR_FORM_ID` in both files

### Step 3: Deploy to DigitalOcean App Platform

1. **Log into DigitalOcean**
2. **Click "Create" → "Apps"**
3. **Select "GitHub"** and authorize
4. **Choose this repository**
   - Branch: `main` (or `master`)
   - Source Directory: `/`
5. **Configure:**
   - Type: Static Site (should auto-detect)
   - Build Command: (leave blank)
   - Output Directory: `/`
6. **Name:** `tech-debt-observatory` (or whatever you want)
7. **Click "Launch Static Site"**
8. **Wait 2-3 minutes** for deployment

You'll get a URL like: `https://tech-debt-observatory-xxxxx.ondigitalocean.app`

### Step 4: Point Your Domain

#### In DigitalOcean:
1. Go to your App
2. Click "Settings" → "Domains"
3. Click "Add Domain"
4. Enter: `debt.bazteksolution.com` (or your preferred subdomain)
5. DigitalOcean will show you DNS records to add

#### In GoDaddy:
1. Log in to GoDaddy
2. Go to "My Products" → "Domains"
3. Click your domain → "DNS"
4. Add CNAME record:
   - Type: `CNAME`
   - Name: `debt` (or your subdomain)
   - Value: `[your-app].ondigitalocean.app`
   - TTL: `600`
5. Save
6. Wait 10-60 minutes for DNS propagation

SSL certificate will auto-generate (free via Let's Encrypt).

## 🎨 Customization

### Change Colors

All pages use inline CSS. To change the color scheme, find:
```css
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
```

And replace with your preferred colors.

### Update Content

Each HTML file is self-contained. Edit directly in GitHub or locally.

### Add More Pages

Follow the same structure - copy any existing page as a template.

## 📊 Analytics (Optional)

To add privacy-friendly analytics:

1. Sign up at https://plausible.io (paid) or self-host
2. Add to the `<head>` of each page:
```html
<script defer data-domain="your-domain.com" 
        src="https://plausible.io/js/script.js"></script>
```

## 🔒 Privacy

This site:
- ✅ Collects NO personal data
- ✅ No tracking cookies
- ✅ No third-party scripts (except Formspree for contact)
- ✅ Contact form forwards to anonymous email
- ✅ Open source and transparent

## 🛠️ Local Development

To test locally:

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/tech-debt-showcase.git
cd tech-debt-showcase

# Open in browser (no build needed)
open index.html
# or
python3 -m http.server 8000
# then visit http://localhost:8000
```

## 📝 Making Updates

After pushing changes to GitHub, DigitalOcean automatically redeploys (1-2 minutes).

## 🎯 Launch Checklist

- [ ] Repository created on GitHub
- [ ] Formspree account set up with Apple Hide My Email
- [ ] Form IDs updated in index.html and scale.html
- [ ] DigitalOcean App Platform connected to GitHub
- [ ] Site deployed and accessible
- [ ] Domain DNS configured in GoDaddy
- [ ] SSL certificate generated (automatic)
- [ ] Test all pages load correctly
- [ ] Test contact form submission
- [ ] Review on mobile device

## 🚀 Launch Strategy

### Hacker News Post (Recommended)

**Title:** "AI Analysis of OpenSSL's Technical Debt [Show HN]"

**Body:**
```
I'm an anonymous systems programmer (System/360 era) 
exploring whether AI can identify technical debt at scale.

Gave Claude one file from OpenSSL. It found:
- 12 critical issues in 75 seconds
- Unchecked integer overflows
- Memory safety concerns
- Detailed remediation steps

Full analysis and methodology: [your-url]

Not selling anything. Just showing what's possible.
Curious about feedback, especially from maintainers.
```

**Best time to post:** Sunday evening or Monday morning (US time)

### Reddit

Post to:
- r/programming
- r/netsec (OpenSSL is security-critical)
- r/opensource

### What to Expect

- Lots of questions about methodology
- Some skepticism (normal and healthy)
- Requests to analyze other projects
- Technical discussions about findings
- Debate about AI capabilities

**Stay humble. Listen to feedback. Iterate.**

## 💡 Next Steps

Based on feedback, consider:

1. Analyze full OpenSSL codebase
2. Add 4-5 more critical projects
3. Build interactive dashboard
4. Weekly automated updates
5. API for security tools integration

## 📧 Questions?

This is an anonymous project, but you can reach out via the contact form on the site.

## 📜 License

The analysis methodology and site code are open and reproducible.
All analyzed code is from public open source repositories.

---

**Remember:** This is about helping maintainers, not criticizing them. 
Frame everything positively. Focus on improvement, not shame.

Good luck! 🚀
