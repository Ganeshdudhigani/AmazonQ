#"generate a reusable YAML template for a CI/CD pipeline to build,test, and deploy a Node.js application."
# Node.js CI/CD Pipeline Template
name: Node.js CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

env:
  NODE_VERSION: '16.x'
  
jobs:
  build-and-test:
    name: Build and Test
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'
        
    - name: Install Dependencies  
      run: npm ci
      
    - name: Run Linter
      run: npm run lint
      
    - name: Run Tests
      run: npm test
      
    - name: Build Application
      run: npm run build
      
    - name: Upload Build Artifacts
      uses: actions/upload-artifact@v3
      with:
        name: build-files
        path: dist/

  deploy-staging:
    name: Deploy to Staging
    needs: build-and-test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    
    steps:
    - name: Download Build Artifacts
      uses: actions/download-artifact@v3
      with:
        name: build-files
        path: dist/
        
    - name: Deploy to Staging Server
      run: |
        # Add deployment commands here
        echo "Deploying to staging environment"

  deploy-production:
    name: Deploy to Production
    needs: build-and-test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    environment:
      name: production
      url: https://your-production-url.com
    
    steps:
    - name: Download Build Artifacts
      uses: actions/download-artifact@v3
      with:
        name: build-files
        path: dist/
        
    - name: Deploy to Production
      run: |
        # Add deployment commands here
        echo "Deploying to production environment"
