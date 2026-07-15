const CLOUD_NAME = import.meta.env.VITE_CLOUDINARY_CLOUD_NAME;
const UPLOAD_PRESET = import.meta.env.VITE_CLOUDINARY_UPLOAD_PRESET;

export const uploadVideoToCloudinary = async (
  file: File,
  onProgress?: (progress: number) => void
): Promise<{ url: string; public_id: string }> => {
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    const formData = new FormData();
    formData.append('file', file);
    formData.append('upload_preset', UPLOAD_PRESET);
    formData.append('resource_type', 'video');

    xhr.open(
      'POST',
      `https://api.cloudinary.com/v1_1/${CLOUD_NAME}/video/upload`
    );

    xhr.upload.onprogress = (event) => {
      if (event.lengthComputable && onProgress) {
        const progress = Math.round((event.loaded / event.total) * 100);
        onProgress(progress);
      }
    };

    xhr.onload = () => {
      if (xhr.status === 200) {
        const response = JSON.parse(xhr.responseText);
        // Optimize video delivery URL
        const optimizedUrl = response.secure_url.replace(
          '/upload/',
          '/upload/f_auto,q_auto/'
        );
        resolve({ url: optimizedUrl, public_id: response.public_id });
      } else {
        reject(new Error('Failed to upload video'));
      }
    };

    xhr.onerror = () => reject(new Error('Network error occurred'));
    xhr.send(formData);
  });
};
