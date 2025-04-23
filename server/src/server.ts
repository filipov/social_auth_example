// server.ts
import express from 'express';
import axios from 'axios';
import jwt from 'jsonwebtoken';
import cors from 'cors';
import {verifySocialToken} from "./auth-utils";

const app = express();
app.use(cors());
app.use(express.json());

const JWT_SECRET = 'your_super_secret_key'; // Замените на надежный секрет
const PORT = 3000;

// Маршрут для верификации токена и выдачи JWT
app.post('/auth/:provider', async (req, res) => {
  try {
    const { provider } = req.params;
    const { accessToken } = req.body;

    // Верификация токена через API провайдера
    const userData = await verifySocialToken(provider, accessToken);

    // Создание JWT
    const appToken = jwt.sign(
      {
        userId: userData.id,
        provider: provider,
        email: userData.email
      },
      JWT_SECRET,
      { expiresIn: '1h' }
    );

    res.json({ token: appToken });
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
});

// Маршрут для получения данных пользователя
app.get('/user', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) throw new Error('No token');

    const decoded = jwt.verify(token, JWT_SECRET) as jwt.JwtPayload;

    // Запрос данных из соцсети через сервер (для безопасности)
    const userData = await fetchSocialData(
      decoded.provider,
      decoded.userId,
      token
    );

    res.json(userData);
  } catch (error) {
    res.status(401).json({ error: 'Unauthorized' });
  }
});

// Запуск сервера
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});