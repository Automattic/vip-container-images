FROM nginx:1.22.0-alpine@sha256:f335d7436887b39393409261603fb248e0c385ec18997d866dd44f7e9b621096

RUN apk add --no-cache openssl

COPY nginx/default.conf /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]