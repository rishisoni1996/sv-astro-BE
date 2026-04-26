<<<<<<< HEAD
# NestJS Boilerplate

A production-ready NestJS boilerplate with TypeORM, authentication, and CRUD operations.

## Features

- TypeORM integration with PostgreSQL
- JWT Authentication with guest user support
- CRUD operations for users and posts
- Proper error handling
- Input validation using class-validator
- Environment configuration
- Database migrations
- Pre-commit hooks with ESLint and Prettier
- TypeScript configuration
- Comprehensive documentation

## Prerequisites

- Node.js (v16 or later)
- PostgreSQL
- npm or yarn

## Installation

1. Clone the repository:

```bash
git clone <repository-url>
cd nestjs-boilerplate
```

2. Install dependencies:

```bash
npm install
```

3. Create a `.env` file in the root directory and configure your environment variables:

```env
# Application
PORT=3000
NODE_ENV=development

# Database
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_DATABASE=nestjs_boilerplate

# JWT
JWT_SECRET=your-super-secret-key
JWT_EXPIRATION=1d
```

4. Create the database:

```bash
createdb nestjs_boilerplate
```

5. Run migrations:

```bash
npm run migration:run
```

## Development

Start the development server:

```bash
npm run start:dev
```

The application will be available at `http://localhost:3000`.

## API Endpoints

### Authentication

- `POST /auth/login` - Login with email and password
- `POST /auth/guest` - Create a guest user account

### Users

- `POST /users` - Create a new user
- `GET /users` - Get all users
- `GET /users/:id` - Get a specific user
- `PATCH /users/:id` - Update a user
- `DELETE /users/:id` - Delete a user

## Database Migrations

Generate a new migration:

```bash
npm run migration:generate -- -n <migration-name>
```

Run migrations:

```bash
npm run build && npm run migration:run
```

Revert migrations:

```bash
npm run migration:revert
```

## Testing

Run unit tests:

```bash
npm run test
```

Run e2e tests:

```bash
npm run test:e2e
```

## Code Quality

Format code:

```bash
npm run format
```

Lint code:

```bash
npm run lint
```

## Production

Build the application:

```bash
npm run build
```

Start the production server:

```bash
npm run start:prod
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
=======
# flutter_base

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
>>>>>>> 69854988d6629a0bd8bf85a30fb26bc4d49156f0
