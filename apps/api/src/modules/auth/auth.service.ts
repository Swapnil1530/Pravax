import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

interface LoginInput {
  email: string;
  password: string;
}

interface LoginResult {
  accessToken: string;
}

@Injectable()
export class AuthService {
  constructor(private readonly jwtService: JwtService) {}

  async validateUser(email: string, password: string): Promise<{ id: string; email: string } | null> {
    // Placeholder: replace with DB user lookup and password verify
    if (email === 'admin@local' && password === 'admin') {
      return { id: '1', email };
    }
    return null;
  }

  async login({ email, password }: LoginInput): Promise<LoginResult> {
    const user = await this.validateUser(email, password);
    if (!user) {
      throw new Error('Invalid credentials');
    }
    const payload = { sub: user.id, email: user.email };
    const accessToken = await this.jwtService.signAsync(payload);
    return { accessToken };
  }
}


