import express from 'express';
import cors from 'cors';
import { getGoogleUserData, GoogleUserData } from './providers/getGoogleUserData';
import { getYandexUserData, YandexUserData } from './providers/getYandexUserData';
import { getVKUserData, VKUserData } from './providers/getVKUserData';

const app = express();

app.use(cors());
app.use(express.urlencoded());
app.use(express.json());

type ProviderNames = 'google' | 'yandex' | 'vk';
type ProviderFunction =
  (accessToken: string, clientId?: string) => Promise<GoogleUserData | YandexUserData | VKUserData>;

const providers: Record<ProviderNames, ProviderFunction> = {
  google: getGoogleUserData,
  yandex: getYandexUserData,
  vk: getVKUserData,
}

type UserData = GoogleUserData & YandexUserData & VKUserData;

// Маршрут для верификации токена и выдачи JWT
app.post('/auth/:provider', async (req, res) => {
  try {
    const { provider } = req.params;
    const { accessToken, clientId } = req.body;
    
    if (Object.keys(providers).includes(provider)) {
      const data = await providers[provider as ProviderNames](accessToken, clientId) as  UserData;
      
      return res.json({
        id: data.sub || data.id || data.user.user_id,
        email: data.email || data.default_email || data.user.email,
        name: data.name || data.real_name || `${data.user.first_name} ${data.user.last_name}`,
      });
    }
    
    res.status(401).json({ error: 'Provider not found' });
  } catch (error) {
    console.log(error);
    
    res.status(401).json({ error: 'Invalid token' });
  }
});

app.listen(3000, '0.0.0.0', () => {
  console.log('Server running on port 3000');
})