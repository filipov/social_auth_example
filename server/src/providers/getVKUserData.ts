export interface VKUserData {
  user: {
    user_id: number;
    first_name: string;
    last_name: string;
    avatar?: string;
    email?: string;
  };
}

export async function getVKUserData(accessToken: string, clientId?: string): Promise<VKUserData> {
  const body = new FormData();
  if (clientId) {
    body.append('client_id', clientId);
  }
  body.append('access_token', accessToken);
  
  const response = await fetch('https://id.vk.com/oauth2/user_info', {
    method: 'POST',
    headers: {
      'Accept': 'application/json'
    },
    body,
  });
  
  const rawData = await response.text();
  
  if (!response.ok) {
    const errorData = JSON.parse(rawData);
    throw new Error(`VK ID Error: ${errorData.error} - ${errorData.error_description}`);
  }
  
  const data = JSON.parse(rawData);
  
  if ((data as Record<'error' | 'error_description', string>).error) {
    throw new Error(`VK ID Error: ${data.error} - ${data.error_description}`);
  }
  
  return data as VKUserData;
}