export interface GoogleUserData {
  sub: string;
  name?: string;
  given_name?: string;
  family_name?: string;
  picture?: string;
  email?: string;
  email_verified?: boolean;
  locale?: string;
  hd?: string;
}

export async function getGoogleUserData(accessToken: string): Promise<GoogleUserData> {
  const response = await fetch('https://www.googleapis.com/oauth2/v3/userinfo', {
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  });
  
  if (!response.ok) {
    const errorData = await response.json();
    
    throw new Error(`Google API Error: ${errorData.error} (${errorData.error_description || 'No description'})`);
  }
  
  return await response.json();
}
