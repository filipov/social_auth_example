export interface YandexUserData {
  id: string;
  login: string;
  client_id: string;
  display_name?: string;
  real_name?: string;
  first_name?: string;
  last_name?: string;
  sex?: 'male' | 'female' | 'unknown';
  default_email: string;
  emails?: string[];
  default_avatar_id?: string;
  is_avatar_empty?: boolean;
  psuid?: string;
}

export async function getYandexUserData(accessToken: string): Promise<YandexUserData> {
  try {
    const apiUrl = new URL('https://login.yandex.ru/info');
    apiUrl.searchParams.append('format', 'json');
    apiUrl.searchParams.append('oauth_token', accessToken);
    
    const response = await fetch(apiUrl.toString(), {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
      }
    });
    
    // Для диагностики можно записать сырой ответ
    const rawResponse = await response.text();
    
    if (!response.ok) {
      let errorMessage = `HTTP Error ${response.status}`;
      try {
        const errorData = JSON.parse(rawResponse);
        errorMessage += `: ${errorData.error_description || errorData.error}`;
      } catch (e) {
        errorMessage += ` - ${rawResponse}`;
      }
      throw new Error(errorMessage);
    }
    
    const userData: YandexUserData = JSON.parse(rawResponse);
    
    // Валидация обязательных полей
    if (!userData.id || !userData.default_email) {
      throw new Error('Invalid user data structure from Yandex API');
    }
    
    return userData;
  } catch (error) {
    if (error instanceof Error) {
      throw new Error(`Yandex API request failed: ${error.message}`);
    }
    throw new Error('Unknown error during Yandex API request');
  }
}
