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
  const containerRef = useRef<HTMLDivElement>(null);

  // Debug logging
  useEffect(() => {
    console.log('ImageCropper mounted, imageSrc:', imageSrc ? 'exists' : 'missing');
    console.log('Initial crop:', crop);
  }, []);

  useEffect(() => {
    console.log('Crop changed:', crop);
  }, [crop]);

  useEffect(() => {
    console.log('CompletedCrop changed:', completedCrop);
  }, [completedCrop]);

  const onImageLoad = useCallback((e: React.SyntheticEvent<HTMLImageElement>) => {
    const { width, height } = e.currentTarget;
    console.log('Image loaded, dimensions:', width, height);
    
    // Set completed crop based on initial percentage crop
    const x = width * 0.1;
    const y = height * 0.1;
    const cropWidth = width * 0.8;
    const cropHeight = height * 0.8;
    
    setCompletedCrop({
      unit: 'px',
      x,
      y,
      width: cropWidth,
      height: cropHeight,
    });
  }, []);

  const getCroppedImg = useCallback((): Promise<string> => {
    return new Promise((resolve, reject) => {
      const image = imgRef.current;
      console.log('getCroppedImg called, image:', !!image, 'completedCrop:', !!completedCrop);
      
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

      ctx.drawImage(
        image,
        cropX,
        cropY,
        cropWidth,
        cropHeight,
        0,
        0,
        cropWidth,
        cropHeight,
      );

      // Compress to max 1024px dimension
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

  const handleUsePhoto = useCallback(async () => {
    console.log('handleUsePhoto called');
    try {
      const croppedImage = await getCroppedImg();
      console.log('Cropped image generated, length:', croppedImage.length);
      onCropComplete(croppedImage);
    } catch (error) {
      console.error('Crop error:', error);
    }
  }, [getCroppedImg, onCropComplete]);

  const handleCancel = useCallback(() => {
    console.log('handleCancel called');
    onCancel();
  }, [onCancel]);

  const handleCropChange = useCallback((c: Crop, percentCrop: Crop) => {
    console.log('Crop onChange:', percentCrop);
    setCrop(percentCrop);
  }, []);

  const handleCropComplete = useCallback((c: PixelCrop) => {
    console.log('Crop onComplete:', c);
    setCompletedCrop(c);
  }, []);

  const cropperContent = (
    <div 
      ref={containerRef}
      style={{ 
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        zIndex: 99999,
        backgroundColor: '#000',
        display: 'flex',
        flexDirection: 'column',
        overflow: 'hidden',
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
        }}
      >
        <button
          type="button"
          onPointerDown={(e) => {
            e.stopPropagation();
            console.log('X button pointerdown');
          }}
          onClick={(e) => {
            e.preventDefault();
            e.stopPropagation();
            console.log('X button clicked');
            handleCancel();
          }}
          onTouchEnd={(e) => {
            e.preventDefault();
            e.stopPropagation();
            console.log('X button touchend');
            handleCancel();
          }}
          style={{ 
            padding: '12px',
            color: '#fff',
            background: 'transparent',
            border: 'none',
            borderRadius: '50%',
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            WebkitTapHighlightColor: 'transparent',
            touchAction: 'manipulation',
          }}
        >
          <X size={24} />
        </button>
        <h2 
          style={{ 
            fontSize: '16px',
            fontWeight: 600,
            color: '#fff',
            margin: 0,
          }}
        >
          이미지 자르기
        </h2>
        <div style={{ width: '48px' }} />
      </div>

      {/* Crop Area */}
      <div 
        style={{ 
          flex: 1,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          overflow: 'hidden',
          padding: '8px',
          backgroundColor: '#000',
        }}
      >
        <ReactCrop
          crop={crop}
          onChange={handleCropChange}
          onComplete={handleCropComplete}
          keepSelection
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
          />
        </ReactCrop>
      </div>

      {/* Action Button */}
      <div 
        style={{ 
          padding: '16px',
          paddingBottom: '32px',
          backgroundColor: '#000',
          flexShrink: 0,
        }}
      >
        <button
          type="button"
          onPointerDown={(e) => {
            e.stopPropagation();
            console.log('Use photo button pointerdown');
          }}
          onClick={(e) => {
            e.preventDefault();
            e.stopPropagation();
            console.log('Use photo button clicked');
            handleUsePhoto();
          }}
          onTouchEnd={(e) => {
            e.preventDefault();
            e.stopPropagation();
            console.log('Use photo button touchend');
            handleUsePhoto();
          }}
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
            WebkitTapHighlightColor: 'transparent',
            touchAction: 'manipulation',
          }}
        >
          <Check size={20} />
          사진 사용
        </button>
      </div>
    </div>
  );

  return createPortal(cropperContent, document.body);
}
