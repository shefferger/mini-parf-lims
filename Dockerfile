FROM nginx:alpine

# Создаем директорию для сертификатов
RUN mkdir -p /etc/nginx/ssl

# Копируем конфигурацию nginx
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80 8080

CMD ["nginx", "-g", "daemon off;"]
