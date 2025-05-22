# 📦 PGNode: PostgreSQL + Node.js Environment
**Repository:** `nndwn/pgnode`  
**Version:** `0.1.1`

PGNode is a **Docker image combining PostgreSQL and Node.js**, designed for developers who need a seamless database and JavaScript environment.

## 🚀 Key Features
- ✅ **Pre-configured PostgreSQL** with automated user & database setup.
- ✅ **Fast Node Manager (fnm)** for easy Node.js version management.
- ✅ **Automatic timezone setting to `Asia/Jakarta`** for local compatibility.
- ✅ **Persistent PostgreSQL storage**, ensuring data remains intact across restarts.

## 📌 How to Use
Run the container using the following command:
```sh
docker run -it \
  -e USER_PG=myuser \
  -e PWD_PG=mypassword \
  -e DB_PG=mydatabase \
  -e TZ=Asia/Jakarta \  # ✅ Set timezone explicitly
  -v my_pg_data:/var/lib/postgresql/data \
  -v $(pwd)/app:/app \
  nndwn/pgnode:0.1.1
```
To integrate PGNode into Docker Compose, add the following to your docker-compose.yml:

```yaml
services:
  pgnode:
    image: nndwn/pgnode:0.1.1
    environment:
      USER_PG: myuser
      PWD_PG: mypassword
      DB_PG: mydatabase
      TZ: Asia/Jakarta 
    volumes:
      - my_pg_data:/var/lib/postgresql/data
      - ./app:/app
    working_dir: /app
    ports:
      - "5432:5432"

volumes:
  my_pg_data:
```