import { useState, useRef, useCallback, useEffect } from 'react';
import { createPortal } from 'react-dom';
import ReactCrop, { Crop, PixelCrop } from 'react-image-crop';
import 'react-image-crop/dist/ReactCrop.css';
import { X, Check } from 'lucide-react';

interface ImageCropperProps {
  imageSrc: string;
  onCropComplete: (croppedImageBase64: string) => void;
  onCancel: () => void;
}

export function ImageCropper({ imageSrc, onCropComplete, onCancel }: ImageCropperProps) {
  const [crop, setCrop] = useState<Crop>({
    unit: '%',
    x: 10,
    y: 10,
    width: 80,
    height: 80,
  });
  const [completedCrop, setCompletedCrop] = useState<PixelCrop>();
  const imgRef = useRef<HTMLImageElement>(null);

  // Prevent body scroll and touch events when cropper is open
  useEffect(() => {
    const originalStyle = document.body.style.cssText;
    const originalHtmlStyle = document.documentElement.style.cssText;
    
    document.body.style.cssText = `${originalStyle}; overflow: hidden !important; position: fixed !important; width: 100% !important;`;
    document.documentElement.style.cssText = `${originalHtmlStyle}; overflow: hidden !important;`;
    
    return () => {
      document.body.style.cssText = originalStyle;
      document.documentElement.style.cssText = originalHtmlStyle;
    };
  }, []);

  const onImageLoad = useCallback((e: React.SyntheticEvent<HTMLImageElement>) => {
    const { width, height } = e.currentTarget;
    
    setCompletedCrop({
      unit: 'px',
      x: width * 0.1,
      y: height * 0.1,
      width: width * 0.8,
      height: height * 0.8,
    });
  }, []);

  const getCroppedImg = useCallback((): Promise<string> => {
    return new Promise((resolve, reject) => {
      const image = imgRef.current;
      
      if (!image || !completedCrop) {
        reject(new Error('Image or crop not available'));
        return;
      }

      const canvas = document.createElement('canvas');
      const ctx = canvas.getContext('2d');
      if (!ctx) {
        reject(new Error('Canvas context not available'));
        return;
      }

      const scaleX = image.naturalWidth / image.width;
      const scaleY = image.naturalHeight / image.height;

      const cropX = completedCrop.x * scaleX;
      const cropY = completedCrop.y * scaleY;
      const cropWidth = completedCrop.width * scaleX;
      const cropHeight = completedCrop.height * scaleY;

      canvas.width = cropWidth;
      canvas.height = cropHeight;

      ctx.drawImage(image, cropX, cropY, cropWidth, cropHeight, 0, 0, cropWidth, cropHeight);

      // Compress to max 1024px
      const maxDimension = 1024;
      let finalWidth = canvas.width;
      let finalHeight = canvas.height;

      if (finalWidth > maxDimension || finalHeight > maxDimension) {
        if (finalWidth > finalHeight) {
          finalHeight = (finalHeight / finalWidth) * maxDimension;
          finalWidth = maxDimension;
        } else {
          finalWidth = (finalWidth / finalHeight) * maxDimension;
          finalHeight = maxDimension;
        }
      }

      const finalCanvas = document.createElement('canvas');
      const finalCtx = finalCanvas.getContext('2d');
      if (!finalCtx) {
        reject(new Error('Final canvas context not available'));
        return;
      }

      finalCanvas.width = finalWidth;
      finalCanvas.height = finalHeight;
      finalCtx.drawImage(canvas, 0, 0, finalWidth, finalHeight);

      resolve(finalCanvas.toDataURL('image/jpeg', 0.85));
    });
  }, [completedCrop]);

  const handleUsePhoto = async () => {
    try {
      const croppedImage = await getCroppedImg();
      onCropComplete(croppedImage);
    } catch (error) {
      console.error('Crop error:', error);
    }
  };

  return createPortal(
    <div 
      className="image-cropper-overlay"
      style={{ 
        position: 'fixed',
        inset: 0,
        zIndex: 99999,
        backgroundColor: '#000',
        display: 'flex',
        flexDirection: 'column',
        overflow: 'hidden',
        touchAction: 'none',
      }}
    >
      {/* Header */}
      <div 
        style={{ 
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          padding: '12px 16px',
          backgroundColor: '#000',
          flexShrink: 0,
          zIndex: 10,
        }}
      >
        <button
          type="button"
          onClick={onCancel}
          style={{ 
            padding: '12px',
            color: '#fff',
            background: 'rgba(255,255,255,0.15)',
            border: 'none',
            borderRadius: '50%',
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            touchAction: 'manipulation',
          }}
        >
          <X size={24} />
        </button>
        <h2 style={{ fontSize: '16px', fontWeight: 600, color: '#fff', margin: 0 }}>
          이미지 자르기
        </h2>
        <div style={{ width: '48px' }} />
      </div>

      {/* Crop Area */}
      <div 
        className="crop-container"
        style={{ 
          flex: 1,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          overflow: 'hidden',
          padding: '8px',
          touchAction: 'none',
        }}
      >
        <ReactCrop
          crop={crop}
          onChange={(_, percentCrop) => setCrop(percentCrop)}
          onComplete={(c) => setCompletedCrop(c)}
          keepSelection
          className="image-cropper-react-crop"
        >
          <img
            ref={imgRef}
            src={imageSrc}
            alt="Crop preview"
            onLoad={onImageLoad}
            style={{ 
              maxHeight: '55vh', 
              maxWidth: '100%', 
              objectFit: 'contain',
              display: 'block',
            }}
            draggable={false}
          />
        </ReactCrop>
      </div>

      {/* Action Button */}
      <div 
        style={{ 
          padding: '16px',
          paddingBottom: 'max(32px, env(safe-area-inset-bottom))',
          backgroundColor: '#000',
          flexShrink: 0,
          zIndex: 10,
        }}
      >
        <button
          type="button"
          onClick={handleUsePhoto}
          disabled={!completedCrop?.width || !completedCrop?.height}
          style={{ 
            width: '100%',
            height: '48px',
            borderRadius: '8px',
            border: 'none',
            backgroundColor: '#f97316',
            color: '#fff',
            fontSize: '16px',
            fontWeight: 600,
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '8px',
            opacity: (!completedCrop?.width || !completedCrop?.height) ? 0.5 : 1,
            touchAction: 'manipulation',
          }}
        >
          <Check size={20} />
          사진 사용
        </button>
      </div>
    </div>,
    document.body
  );
}