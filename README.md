# Card Distribution Application

A full-stack web application for managing and distributing cards, built with Laravel backend and React frontend.

## 🏗️ Project Structure

The project follows a modern microservices architecture with separate backend and frontend services:

```
├── backend (Laravel API)
├── frontend (React Application)
└── docker (Development Environment)
```

## 🚀 Features

- RESTful API for card management
- Card distribution system
- Docker containerization
- Automated testing
- CI/CD pipeline integration

## 🛠️ Technology Stack

### Backend
- PHP 8.x
- Laravel Framework
- MySQL/MariaDB/PostgreSQL (configurable)
- PHPUnit for testing

### Frontend
- React.js
- Modern JavaScript (ES6+)
- CSS3 with Tailwind CSS
- Jest for testing

### DevOps
- Docker & Docker Compose
- GitHub Actions for CI/CD
- Multiple PHP version support (8.0 - 8.4)

## 📦 Installation

### Prerequisites
- Docker and Docker Compose
- Node.js (v16 or higher)
- Composer

### Setup Steps

1. Clone the repository:
```bash
git clone https://github.com/3m-abro/card-distribution.git 
cd card-distribution
```

2. Set up the backend:
```bash
cd backend
cp .env.example .env
composer install
php artisan key:generate
php artisan migrate
php artisan db:seed --class=CardSeeder
```

3. Set up the frontend:
```bash
cd frontend
npm install
```

4. Start the development environment:
```bash
docker-compose up -d --build
```

## 🏃‍♂️ Running the Application

### Development Mode

1. Start the backend server:
```bash
cd backend
php artisan serve
```

2. Start the frontend development server:
```bash
cd frontend
npm start
```

### Using Docker

```bash
docker-compose up -d
```

The application will be available at:
- Frontend: http://localhost:3000
- Backend API: http://localhost:9000

## 🧪 Testing

### Backend Tests
```bash
cd backend
php artisan test
```

### Frontend Tests
```bash
cd frontend
npm test
```

## 📁 Project Structure Details

### Backend Structure
- `app/Http/Controllers`: API endpoints logic
- `app/Models`: Database models (User, Card)
- `app/Http/Resources`: API resource transformers
- `database/migrations`: Database structure
- `database/seeders`: Initial data seeders
- `routes`: API and web routes
- `tests`: Feature and unit tests

### Frontend Structure
- `src/components`: React components
- `src/services`: API integration services
- `src/tests`: Component and integration tests

## 🔒 Environment Configuration

### Backend (.env)
Required environment variables:
```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=card_distribution
DB_USERNAME=root
DB_PASSWORD=
```

### Frontend
Configure the API endpoint in `src/services/api.js`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Support

For support, please open an issue in the GitHub repository or contact the maintainers.
