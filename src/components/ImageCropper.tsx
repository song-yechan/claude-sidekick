import { useState, useRef, useCallback, useEffect } from 'react';
import { createPortal } from 'react-dom';
import { X, Check } from 'lucide-react';

interface ImageCropperProps {
  imageSrc: string;
  onCropComplete: (croppedImageBase64: string) => void;
  onCancel: () => void;
}

interface Point {
  x: number;
  y: number;
}

export function ImageCropper({ imageSrc, onCropComplete, onCancel }: ImageCropperProps) {
  const [imageLoaded, setImageLoaded] = useState(false);
  const [imageDimensions, setImageDimensions] = useState({ width: 0, height: 0, naturalWidth: 0, naturalHeight: 0 });
  // 4 corners: top-left, top-right, bottom-right, bottom-left
  const [corners, setCorners] = useState<Point[]>([
    { x: 0, y: 0 },
    { x: 0, y: 0 },
    { x: 0, y: 0 },
    { x: 0, y: 0 },
  ]);
  const [activeCorner, setActiveCorner] = useState<number | null>(null);
  const [dragStart, setDragStart] = useState<Point>({ x: 0, y: 0 });
  const [initialCorner, setInitialCorner] = useState<Point>({ x: 0, y: 0 });
  
  const imageRef = useRef<HTMLImageElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);

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
    
    // Initialize corners with 10% margin
    const margin = 0.1;
    setCorners([
      { x: width * margin, y: height * margin }, // top-left
      { x: width * (1 - margin), y: height * margin }, // top-right
      { x: width * (1 - margin), y: height * (1 - margin) }, // bottom-right
      { x: width * margin, y: height * (1 - margin) }, // bottom-left
    ]);
    setImageLoaded(true);
  }, []);

  const getEventPosition = (e: React.TouchEvent | React.MouseEvent | TouchEvent | MouseEvent): Point => {
    if ('touches' in e && e.touches.length > 0) {
      return { x: e.touches[0].clientX, y: e.touches[0].clientY };
    }
    if ('clientX' in e) {
      return { x: e.clientX, y: e.clientY };
    }
    return { x: 0, y: 0 };
  };

  const handleCornerStart = (e: React.TouchEvent | React.MouseEvent, cornerIndex: number) => {
    e.preventDefault();
    e.stopPropagation();
    
    const pos = getEventPosition(e);
    setDragStart(pos);
    setInitialCorner({ ...corners[cornerIndex] });
    setActiveCorner(cornerIndex);
  };

  const handleMove = useCallback((e: React.TouchEvent | React.MouseEvent) => {
    if (activeCorner === null) return;
    
    e.preventDefault();
    const pos = getEventPosition(e);
    const deltaX = pos.x - dragStart.x;
    const deltaY = pos.y - dragStart.y;
    
    const { width: imgWidth, height: imgHeight } = imageDimensions;
    
    let newX = initialCorner.x + deltaX;
    let newY = initialCorner.y + deltaY;
    
    // Constrain to image bounds with small padding
    const padding = 10;
    newX = Math.max(padding, Math.min(newX, imgWidth - padding));
    newY = Math.max(padding, Math.min(newY, imgHeight - padding));
    
    setCorners(prev => {
      const newCorners = [...prev];
      newCorners[activeCorner] = { x: newX, y: newY };
      return newCorners;
    });
  }, [activeCorner, dragStart, initialCorner, imageDimensions]);

  const handleEnd = useCallback(() => {
    setActiveCorner(null);
  }, []);

  const getPolygonPath = () => {
    return corners.map(c => `${c.x},${c.y}`).join(' ');
  };

  const getCroppedImage = useCallback((): string => {
    const img = imageRef.current;
    if (!img || !imageDimensions.width) return '';
    
    const scaleX = imageDimensions.naturalWidth / imageDimensions.width;
    const scaleY = imageDimensions.naturalHeight / imageDimensions.height;
    
    // Scale corners to natural image size
    const scaledCorners = corners.map(c => ({
      x: c.x * scaleX,
      y: c.y * scaleY,
    }));
    
    // Calculate bounding box of the quadrilateral
    const minX = Math.min(...scaledCorners.map(c => c.x));
    const minY = Math.min(...scaledCorners.map(c => c.y));
    const maxX = Math.max(...scaledCorners.map(c => c.x));
    const maxY = Math.max(...scaledCorners.map(c => c.y));
    
    const cropWidth = maxX - minX;
    const cropHeight = maxY - minY;
    
    // Create canvas for perspective transform
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    if (!ctx) return '';
    
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
    
    // For simple quadrilateral crop, we'll use the bounding box approach
    // with clipping path for the actual shape
    ctx.save();
    
    // Create clipping path based on scaled corners relative to crop area
    ctx.beginPath();
    const relativeCorners = scaledCorners.map(c => ({
      x: (c.x - minX) * (finalWidth / cropWidth),
      y: (c.y - minY) * (finalHeight / cropHeight),
    }));
    ctx.moveTo(relativeCorners[0].x, relativeCorners[0].y);
    ctx.lineTo(relativeCorners[1].x, relativeCorners[1].y);
    ctx.lineTo(relativeCorners[2].x, relativeCorners[2].y);
    ctx.lineTo(relativeCorners[3].x, relativeCorners[3].y);
    ctx.closePath();
    ctx.clip();
    
    // Draw the cropped portion
    ctx.drawImage(
      img,
      minX, minY, cropWidth, cropHeight,
      0, 0, finalWidth, finalHeight
    );
    
    ctx.restore();
    
    return canvas.toDataURL('image/jpeg', 0.85);
  }, [corners, imageDimensions]);

  const handleConfirm = () => {
    const croppedImage = getCroppedImage();
    if (croppedImage) {
      onCropComplete(croppedImage);
    }
  };

  const handleClose = () => {
    onCancel();
  };

  // Create overlay mask path (full image with quadrilateral hole)
  const getMaskPath = () => {
    const { width, height } = imageDimensions;
    // Outer rectangle (clockwise)
    // Inner quadrilateral (counter-clockwise to create hole)
    return `M 0,0 L ${width},0 L ${width},${height} L 0,${height} Z 
            M ${corners[0].x},${corners[0].y} 
            L ${corners[3].x},${corners[3].y} 
            L ${corners[2].x},${corners[2].y} 
            L ${corners[1].x},${corners[1].y} Z`;
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
      onTouchMove={handleMove}
      onMouseMove={handleMove}
      onTouchEnd={handleEnd}
      onMouseUp={handleEnd}
      onMouseLeave={handleEnd}
    >
      {/* Header */}
      <div style={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        padding: '12px 16px',
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

      {/* Crop Area - Maximized */}
      <div style={{
        flex: 1,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '8px',
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
              maxWidth: 'calc(100vw - 16px)',
              maxHeight: 'calc(100vh - 160px)',
              display: 'block',
              pointerEvents: 'none',
            }}
            draggable={false}
          />
          
          {imageLoaded && imageDimensions.width > 0 && (
            <svg
              style={{
                position: 'absolute',
                top: 0,
                left: 0,
                width: imageDimensions.width,
                height: imageDimensions.height,
                pointerEvents: 'none',
              }}
            >
              {/* Dark overlay with hole for crop area */}
              <path
                d={getMaskPath()}
                fill="rgba(0,0,0,0.6)"
                fillRule="evenodd"
              />
              
              {/* Border of selection */}
              <polygon
                points={getPolygonPath()}
                fill="none"
                stroke="#fff"
                strokeWidth="2"
              />
              
              {/* Connection lines between corners */}
              <line x1={corners[0].x} y1={corners[0].y} x2={corners[1].x} y2={corners[1].y} stroke="rgba(255,255,255,0.5)" strokeWidth="1" strokeDasharray="4,4" />
              <line x1={corners[1].x} y1={corners[1].y} x2={corners[2].x} y2={corners[2].y} stroke="rgba(255,255,255,0.5)" strokeWidth="1" strokeDasharray="4,4" />
              <line x1={corners[2].x} y1={corners[2].y} x2={corners[3].x} y2={corners[3].y} stroke="rgba(255,255,255,0.5)" strokeWidth="1" strokeDasharray="4,4" />
              <line x1={corners[3].x} y1={corners[3].y} x2={corners[0].x} y2={corners[0].y} stroke="rgba(255,255,255,0.5)" strokeWidth="1" strokeDasharray="4,4" />
            </svg>
          )}
          
          {/* Corner handles - separate from SVG for better touch handling */}
          {imageLoaded && corners.map((corner, index) => (
            <div
              key={index}
              style={{
                position: 'absolute',
                left: corner.x,
                top: corner.y,
                width: '36px',
                height: '36px',
                transform: 'translate(-50%, -50%)',
                backgroundColor: '#fff',
                borderRadius: '50%',
                border: '3px solid #f97316',
                cursor: 'grab',
                touchAction: 'none',
                boxShadow: '0 2px 8px rgba(0,0,0,0.3)',
              }}
              onTouchStart={(e) => handleCornerStart(e, index)}
              onMouseDown={(e) => handleCornerStart(e, index)}
            />
          ))}
        </div>
      </div>

      {/* Bottom button */}
      <div style={{
        padding: '12px 16px',
        paddingBottom: 'max(20px, env(safe-area-inset-bottom))',
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