// app.js - Example for Node.js
const express = require('express');
const app = express();

// Get Tailscale IP (optional)
const { execSync } = require('child_process');
let tailscaleIP = '';

try {
  tailscaleIP = execSync('tailscale ip -4').toString().trim();
  console.log(`Tailscale IP: ${tailscaleIP}`);
} catch (error) {
  console.log('Tailscale IP not available');
}

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from Render + Tailscale!',
    tailscale_ip: tailscaleIP,
    service: process.env.RENDER_SERVICE_NAME
  });
});

// app.get('/health', (req, res) => {
//   res.json({ status: 'healthy', tailscale: !!tailscaleIP });
// });

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});