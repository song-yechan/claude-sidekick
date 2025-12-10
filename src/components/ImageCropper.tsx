import { useState, useRef, useCallback, useEffect } from 'react';
import { createPortal } from 'react-dom';
import { X, Check } from 'lucide-react';

interface ImageCropperProps {
  imageSrc: string;
  onCropComplete: (croppedImageBase64: string) => void;
  onCancel: () => void;
}

interface CropArea {
  x: number;
  y: number;
  width: number;
  height: number;
}

export function ImageCropper({ imageSrc, onCropComplete, onCancel }: ImageCropperProps) {
  const [imageLoaded, setImageLoaded] = useState(false);
  const [imageDimensions, setImageDimensions] = useState({ width: 0, height: 0, naturalWidth: 0, naturalHeight: 0 });
  const [cropArea, setCropArea] = useState<CropArea>({ x: 0, y: 0, width: 0, height: 0 });
  const [isDragging, setIsDragging] = useState(false);
  const [isResizing, setIsResizing] = useState<string | null>(null);
  const [dragStart, setDragStart] = useState({ x: 0, y: 0 });
  const [initialCrop, setInitialCrop] = useState<CropArea>({ x: 0, y: 0, width: 0, height: 0 });
  
  const containerRef = useRef<HTMLDivElement>(null);
  const imageRef = useRef<HTMLImageElement>(null);

  // Prevent body scroll
  useEffect(() => {
    const originalStyle = document.body.style.cssText;
    document.body.style.cssText = 'overflow: hidden !important; position: fixed !important; width: 100% !important; height: 100% !important;';
    
    return () => {
      document.body.style.cssText = originalStyle;
    };
  }, []);

  const handleImageLoad = useCallback((e: React.SyntheticEvent<HTMLImageElement>) => {
    const img = e.currentTarget;
    const { width, height, naturalWidth, naturalHeight } = img;
    
    setImageDimensions({ width, height, naturalWidth, naturalHeight });
    
    // Initialize crop area to 80% of image, centered
    const cropWidth = width * 0.8;
    const cropHeight = height * 0.8;
    const cropX = (width - cropWidth) / 2;
    const cropY = (height - cropHeight) / 2;
    
    setCropArea({ x: cropX, y: cropY, width: cropWidth, height: cropHeight });
    setImageLoaded(true);
  }, []);

  const getEventPosition = (e: React.TouchEvent | React.MouseEvent) => {
    if ('touches' in e && e.touches.length > 0) {
      return { x: e.touches[0].clientX, y: e.touches[0].clientY };
    }
    if ('clientX' in e) {
      return { x: e.clientX, y: e.clientY };
    }
    return { x: 0, y: 0 };
  };

  const handleCropStart = (e: React.TouchEvent | React.MouseEvent, type: 'move' | string) => {
    e.preventDefault();
    e.stopPropagation();
    
    const pos = getEventPosition(e);
    setDragStart(pos);
    setInitialCrop({ ...cropArea });
    
    if (type === 'move') {
      setIsDragging(true);
    } else {
      setIsResizing(type);
    }
  };

  const handleCropMove = useCallback((e: React.TouchEvent | React.MouseEvent) => {
    if (!isDragging && !isResizing) return;
    
    e.preventDefault();
    const pos = getEventPosition(e);
    const deltaX = pos.x - dragStart.x;
    const deltaY = pos.y - dragStart.y;
    
    const minSize = 50;
    const { width: imgWidth, height: imgHeight } = imageDimensions;
    
    if (isDragging) {
      let newX = initialCrop.x + deltaX;
      let newY = initialCrop.y + deltaY;
      
      // Constrain to image bounds
      newX = Math.max(0, Math.min(newX, imgWidth - cropArea.width));
      newY = Math.max(0, Math.min(newY, imgHeight - cropArea.height));
      
      setCropArea(prev => ({ ...prev, x: newX, y: newY }));
    } else if (isResizing) {
      let { x, y, width, height } = initialCrop;
      
      if (isResizing.includes('e')) {
        width = Math.max(minSize, Math.min(initialCrop.width + deltaX, imgWidth - x));
      }
      if (isResizing.includes('w')) {
        const newWidth = Math.max(minSize, initialCrop.width - deltaX);
        const maxWidth = initialCrop.x + initialCrop.width;
        width = Math.min(newWidth, maxWidth);
        x = initialCrop.x + initialCrop.width - width;
      }
      if (isResizing.includes('s')) {
        height = Math.max(minSize, Math.min(initialCrop.height + deltaY, imgHeight - y));
      }
      if (isResizing.includes('n')) {
        const newHeight = Math.max(minSize, initialCrop.height - deltaY);
        const maxHeight = initialCrop.y + initialCrop.height;
        height = Math.min(newHeight, maxHeight);
        y = initialCrop.y + initialCrop.height - height;
      }
      
      setCropArea({ x, y, width, height });
    }
  }, [isDragging, isResizing, dragStart, initialCrop, imageDimensions, cropArea.width, cropArea.height]);

  const handleCropEnd = useCallback(() => {
    setIsDragging(false);
    setIsResizing(null);
  }, []);

  const getCroppedImage = useCallback((): string => {
    const img = imageRef.current;
    if (!img || !imageDimensions.width) return '';
    
    const scaleX = imageDimensions.naturalWidth / imageDimensions.width;
    const scaleY = imageDimensions.naturalHeight / imageDimensions.height;
    
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    if (!ctx) return '';
    
    const cropX = cropArea.x * scaleX;
    const cropY = cropArea.y * scaleY;
    const cropWidth = cropArea.width * scaleX;
    const cropHeight = cropArea.height * scaleY;
    
    // Compress to max 1024px
    const maxDimension = 1024;
    let finalWidth = cropWidth;
    let finalHeight = cropHeight;
    
    if (finalWidth > maxDimension || finalHeight > maxDimension) {
      if (finalWidth > finalHeight) {
        finalHeight = (finalHeight / finalWidth) * maxDimension;
        finalWidth = maxDimension;
      } else {
        finalWidth = (finalWidth / finalHeight) * maxDimension;
        finalHeight = maxDimension;
      }
    }
    
    canvas.width = finalWidth;
    canvas.height = finalHeight;
    ctx.drawImage(img, cropX, cropY, cropWidth, cropHeight, 0, 0, finalWidth, finalHeight);
    
    return canvas.toDataURL('image/jpeg', 0.85);
  }, [cropArea, imageDimensions]);

  const handleConfirm = () => {
    const croppedImage = getCroppedImage();
    if (croppedImage) {
      onCropComplete(croppedImage);
    }
  };

  const handleClose = () => {
    onCancel();
  };

  const handleContainerTouch = (e: React.TouchEvent | React.MouseEvent) => {
    if (isDragging || isResizing) {
      handleCropMove(e);
    }
  };

  const handleContainerTouchEnd = () => {
    handleCropEnd();
  };

  return createPortal(
    <div 
      ref={containerRef}
      style={{
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        zIndex: 999999,
        backgroundColor: '#000',
        display: 'flex',
        flexDirection: 'column',
        touchAction: 'none',
        userSelect: 'none',
        WebkitUserSelect: 'none',
      }}
      onTouchMove={handleContainerTouch}
      onMouseMove={handleContainerTouch}
      onTouchEnd={handleContainerTouchEnd}
      onMouseUp={handleContainerTouchEnd}
      onMouseLeave={handleContainerTouchEnd}
    >
      {/* Header */}
      <div style={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        padding: '16px',
        backgroundColor: '#000',
        flexShrink: 0,
      }}>
        <button
          type="button"
          onTouchEnd={(e) => { e.preventDefault(); handleClose(); }}
          onClick={handleClose}
          style={{
            width: '44px',
            height: '44px',
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
        <span style={{ fontSize: '17px', fontWeight: 600, color: '#fff' }}>
          이미지 자르기
        </span>
        <div style={{ width: '44px' }} />
      </div>

      {/* Crop Area */}
      <div style={{
        flex: 1,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '16px',
        overflow: 'hidden',
        position: 'relative',
      }}>
        <div style={{ position: 'relative', display: 'inline-block' }}>
          <img
            ref={imageRef}
            src={imageSrc}
            alt="Crop"
            onLoad={handleImageLoad}
            style={{
              maxWidth: '100%',
              maxHeight: '70vh',
              display: 'block',
              pointerEvents: 'none',
            }}
            draggable={false}
          />
          
          {imageLoaded && (
            <>
              {/* Dark overlay - top */}
              <div style={{
                position: 'absolute',
                top: 0,
                left: 0,
                right: 0,
                height: cropArea.y,
                backgroundColor: 'rgba(0,0,0,0.6)',
                pointerEvents: 'none',
              }} />
              {/* Dark overlay - bottom */}
              <div style={{
                position: 'absolute',
                bottom: 0,
                left: 0,
                right: 0,
                height: imageDimensions.height - cropArea.y - cropArea.height,
                backgroundColor: 'rgba(0,0,0,0.6)',
                pointerEvents: 'none',
              }} />
              {/* Dark overlay - left */}
              <div style={{
                position: 'absolute',
                top: cropArea.y,
                left: 0,
                width: cropArea.x,
                height: cropArea.height,
                backgroundColor: 'rgba(0,0,0,0.6)',
                pointerEvents: 'none',
              }} />
              {/* Dark overlay - right */}
              <div style={{
                position: 'absolute',
                top: cropArea.y,
                right: 0,
                width: imageDimensions.width - cropArea.x - cropArea.width,
                height: cropArea.height,
                backgroundColor: 'rgba(0,0,0,0.6)',
                pointerEvents: 'none',
              }} />
              
              {/* Crop selection box */}
              <div
                style={{
                  position: 'absolute',
                  top: cropArea.y,
                  left: cropArea.x,
                  width: cropArea.width,
                  height: cropArea.height,
                  border: '2px solid #fff',
                  boxSizing: 'border-box',
                  cursor: 'move',
                }}
                onTouchStart={(e) => handleCropStart(e, 'move')}
                onMouseDown={(e) => handleCropStart(e, 'move')}
              >
                {/* Grid lines */}
                <div style={{ position: 'absolute', top: '33%', left: 0, right: 0, height: '1px', backgroundColor: 'rgba(255,255,255,0.4)' }} />
                <div style={{ position: 'absolute', top: '66%', left: 0, right: 0, height: '1px', backgroundColor: 'rgba(255,255,255,0.4)' }} />
                <div style={{ position: 'absolute', left: '33%', top: 0, bottom: 0, width: '1px', backgroundColor: 'rgba(255,255,255,0.4)' }} />
                <div style={{ position: 'absolute', left: '66%', top: 0, bottom: 0, width: '1px', backgroundColor: 'rgba(255,255,255,0.4)' }} />
                
                {/* Corner handles */}
                {['nw', 'ne', 'sw', 'se'].map((corner) => (
                  <div
                    key={corner}
                    style={{
                      position: 'absolute',
                      width: '28px',
                      height: '28px',
                      backgroundColor: '#fff',
                      borderRadius: '50%',
                      border: '3px solid #f97316',
                      transform: 'translate(-50%, -50%)',
                      cursor: `${corner}-resize`,
                      ...(corner.includes('n') ? { top: 0 } : { bottom: 0, top: 'auto', transform: 'translate(-50%, 50%)' }),
                      ...(corner.includes('w') ? { left: 0 } : { right: 0, left: 'auto', transform: corner.includes('n') ? 'translate(50%, -50%)' : 'translate(50%, 50%)' }),
                    }}
                    onTouchStart={(e) => handleCropStart(e, corner)}
                    onMouseDown={(e) => handleCropStart(e, corner)}
                  />
                ))}
              </div>
            </>
          )}
        </div>
      </div>

      {/* Bottom button */}
      <div style={{
        padding: '16px',
        paddingBottom: 'max(24px, env(safe-area-inset-bottom))',
        backgroundColor: '#000',
        flexShrink: 0,
      }}>
        <button
          type="button"
          onTouchEnd={(e) => { e.preventDefault(); handleConfirm(); }}
          onClick={handleConfirm}
          disabled={!imageLoaded}
          style={{
            width: '100%',
            height: '52px',
            borderRadius: '12px',
            border: 'none',
            backgroundColor: imageLoaded ? '#f97316' : '#666',
            color: '#fff',
            fontSize: '17px',
            fontWeight: 600,
            cursor: imageLoaded ? 'pointer' : 'not-allowed',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '8px',
            touchAction: 'manipulation',
          }}
        >
          <Check size={22} />
          사진 사용
        </button>
      </div>
    </div>,
    document.body
  );
}