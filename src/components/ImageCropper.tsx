import { useState, useRef, useCallback } from 'react';
import ReactCrop, { Crop, PixelCrop, centerCrop, makeAspectCrop } from 'react-image-crop';
import 'react-image-crop/dist/ReactCrop.css';
import { Button } from '@/components/ui/button';
import { X, Check } from 'lucide-react';

interface ImageCropperProps {
  imageSrc: string;
  onCropComplete: (croppedImageBase64: string) => void;
  onCancel: () => void;
}

function centerAspectCrop(
  mediaWidth: number,
  mediaHeight: number,
) {
  return centerCrop(
    makeAspectCrop(
      {
        unit: '%',
        width: 90,
      },
      undefined,
      mediaWidth,
      mediaHeight,
    ),
    mediaWidth,
    mediaHeight,
  );
}

export function ImageCropper({ imageSrc, onCropComplete, onCancel }: ImageCropperProps) {
  const [crop, setCrop] = useState<Crop>();
  const [completedCrop, setCompletedCrop] = useState<PixelCrop>();
  const imgRef = useRef<HTMLImageElement>(null);

  const onImageLoad = useCallback((e: React.SyntheticEvent<HTMLImageElement>) => {
    const { width, height } = e.currentTarget;
    setCrop(centerAspectCrop(width, height));
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

      canvas.width = completedCrop.width * scaleX;
      canvas.height = completedCrop.height * scaleY;

      ctx.drawImage(
        image,
        completedCrop.x * scaleX,
        completedCrop.y * scaleY,
        completedCrop.width * scaleX,
        completedCrop.height * scaleY,
        0,
        0,
        canvas.width,
        canvas.height,
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

  const handleUsePhoto = async () => {
    try {
      const croppedImage = await getCroppedImg();
      onCropComplete(croppedImage);
    } catch (error) {
      console.error('Crop error:', error);
    }
  };

  return (
    <div className="fixed inset-0 z-50 bg-background flex flex-col">
      {/* Header */}
      <div className="flex items-center justify-between px-4 py-3 border-b border-border bg-card">
        <Button
          variant="ghost"
          size="icon"
          onClick={onCancel}
        >
          <X className="h-5 w-5" />
        </Button>
        <h2 className="text-base font-semibold text-foreground">이미지 자르기</h2>
        <div className="w-10" />
      </div>

      {/* Crop Area */}
      <div className="flex-1 flex items-center justify-center p-4 overflow-auto bg-muted/50">
        <ReactCrop
          crop={crop}
          onChange={(_, percentCrop) => setCrop(percentCrop)}
          onComplete={(c) => setCompletedCrop(c)}
          className="max-h-full"
        >
          <img
            ref={imgRef}
            src={imageSrc}
            alt="Crop preview"
            onLoad={onImageLoad}
            className="max-h-[60vh] max-w-full object-contain"
          />
        </ReactCrop>
      </div>

      {/* Action Buttons */}
      <div className="p-4 bg-card border-t border-border">
        <Button
          onClick={handleUsePhoto}
          className="w-full gap-2"
          size="lg"
          disabled={!completedCrop}
        >
          <Check className="h-5 w-5" />
          사진 사용
        </Button>
      </div>
    </div>
  );
}
