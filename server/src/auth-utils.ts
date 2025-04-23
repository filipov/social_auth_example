// auth-utils.ts
import axios from 'axios';

export async function verifySocialToken(provider: string, token: string) {
  switch (provider) {
    case 'google':
      return verifyGoogleToken(token);
    case 'yandex':
      return verifyYandexToken(token);
    case 'vk':
      return verifyVKToken(token);
    default:
      throw new Error('Invalid provider');
  }
}

async function verifyGoogleToken(token: string) {
  const response = await axios.get(
    `https://oauth2.googleapis.com/tokeninfo?access_token=${token}`
  );
  return {
    id: response.data.sub,
    email: response.data.email
  };
}

async function verifyYandexToken(token: string) {
  const response = await axios.post(
    'https://login.yandex.ru/info',
    {},
    { headers: { Authorization: `OAuth ${token}` } }
  );
  return {
    id: response.data.id,
    email: response.data.default_email
  };
}

async function verifyVKToken(token: string) {
  const response = await axios.get(
    `https://api.vk.com/method/users.get?fields=email&access_token=${token}&v=5.131`
  );
  return {
    id: response.data.response[0].id,
    email: response.data.email
  };
}