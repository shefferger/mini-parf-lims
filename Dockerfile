FROM nginx:alpine

# Копируем конфигурацию nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Копируем HTML файл
COPY minilims.html /usr/share/nginx/html/index.html

# Создаем директорию для сертификатов
RUN mkdir -p /etc/nginx/ssl

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]

