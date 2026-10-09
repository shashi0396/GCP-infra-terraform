sudo apt-get update
sudo apt-get install -y nginx

sudo systemctl enable --now nginx
sudo systemctl status nginx

curl http://localhost/
curl http://localhost/nonexistent-page

sudo tail -n 10 /var/log/nginx/access.log
sudo tail -n 10 /var/log/nginx/error.log


sudo systemctl status google-cloud-ops-agent


sudo mkdir -p /etc/google-cloud-ops-agent
sudo touch /etc/google-cloud-ops-agent/config.yaml


sudo tee /etc/google-cloud-ops-agent/config.yaml > /dev/null <<'EOF'
logging:
  receivers:
    nginx_access:
      type: nginx_access
    nginx_error:
      type: nginx_error

  service:
    pipelines:
      nginx:
        receivers:
          - nginx_access
          - nginx_error
EOF


sudo systemctl restart google-cloud-ops-agent
sudo systemctl status google-cloud-ops-agent

curl http://localhost/
curl http://localhost/does-not-exist
sudo tail -n 5 /var/log/nginx/access.log
sudo tail -n 5 /var/log/nginx/error.log