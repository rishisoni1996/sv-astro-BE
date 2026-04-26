import { Request } from 'express';

export interface JwtUser {
  id: string;
  role: string;
}

export interface RequestWithUser extends Request {
  user: JwtUser;
}
