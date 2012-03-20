require "RMagick"

module FilterEffect
  POW_CONST = 65535/255
  class Pixel
    attr_accessor :r, :g, :b, :a
    def initialize(r,g,b,a)
      @r = r
      @g = g
      @b = b
      @a = a
    end
  end

  class Filter
    attr_accessor :image, :url, :core, :blend
    def initialize(url)
      @url = url
      @image = Magick::Image.read(url).first
      @core = Core.new self
      @blend = Blend.new self
    end

    def imageData
      return @image.dispatch(0, 0, @image.columns, @image.rows, "RGBA")
    end

    def safe(i)
      return [255, [0, i.floor].max].min
    end

    def duplicate
      return Filter.new(@url)
    end

    def write_filterred_image(path)
      @image.write(path)
    end
  end

  class Core
    attr_accessor :filter, :width, :height
    def initialize(filtr)
      @filter = filtr
      @width = filtr.image.columns
      @height = filtr.image.rows
    end

    def apply(&block)
      data = @filter.imageData
      (0...@height).each do |i|
        (0...@width).each do |j|
          index = (i*@width*4) + (j*4);
          rgb = yield(
            data[index] / POW_CONST,
            data[index + 1] / POW_CONST,
            data[index + 2] / POW_CONST,
            data[index + 3] / POW_CONST
          )
          data[index]     = rgb.r * POW_CONST
          data[index + 1] = rgb.g * POW_CONST
          data[index + 2] = rgb.b * POW_CONST
          data[index + 3] = rgb.a * POW_CONST

        end
      end
      @filter.image.import_pixels(0, 0, @width, @height, "RGBA", data)
      return self
    end

    def sharpen
      data = self.convolve([
        [0.0, -0.2,  0.0],
        [-0.2, 1.8, -0.2],
        [0.0, -0.2,  0.0]
      ])
      @filter.image.import_pixels(0, 0, @width, @height, "RGBA", data)

      return self;
    end

    def sepia
      self.apply() { |r, g, b, a|
        Pixel.new(
          @filter.safe((r * 0.393) + (g * 0.769) + (b * 0.189)),
          @filter.safe((r * 0.349) + (g * 0.686) + (b * 0.168)),
          @filter.safe((r * 0.272) + (g * 0.534) + (b * 0.131)),
          a
        )
      }
      return self;
    end
    def fill(rF, gF, bF)
      self.apply(){ |r, g, b, a|
          Pixel.new(
          @filter.safe(rF),
          @filter.safe(gF),
          @filter.safe(bF),
          a
        )
      }
      return self
    end
    def adjust(rS, gS, bS)
      self.apply() { |r, g, b, a|
          Pixel.new(
          @filter.safe(r * (1 + rS)),
          @filter.safe(g * (1 + gS)),
          @filter.safe(b * (1 + bS)),
          a
        )
      }
      return self;
    end

    def bias_calc(f, bi)
      return f*1.0 / ((1.0 / bi - 1.9) * (0.9 - f) + 1)
    end
    def bias(val)
      self.apply(){ |r, g, b, a|
        Pixel.new(
          @filter.safe(r * bias_calc(r*1.0 / 255, val)),
          @filter.safe(g * bias_calc(g*1.0 / 255, val)),
          @filter.safe(b * bias_calc(b*1.0 / 255, val)),
          a
        )
      }
      return self;
    end

    def contrast_calc(a, b)
      return (a-0.5) * b + 0.5
    end
    def contrast(val)
      self.apply(){ |r, g, b, a|
        Pixel.new(
          @filter.safe(255 * contrast_calc(r*1.0 / 255, val)),
          @filter.safe(255 * contrast_calc(g*1.0 / 255, val)),
          @filter.safe(255 * contrast_calc(b*1.0 / 255, val)),
          a
        )
      }
      return self;
    end

    def grayScale
      self.apply(){ |r, g, b, a|
        avg = (r + g + b) / 3
        Pixel.new(
          @filter.safe(avg),
          @filter.safe(avg),
          @filter.safe(avg),
          a
        )
      }
      return self;
    end
    def posterize (levels)
      step = (255*1.0 / levels).truncate
      self.apply(){ |r, g, b, a|
          Pixel.new(
          @filter.safe((r*1.0 / step).truncate * step),
          @filter.safe((g*1.0 / step).truncate * step),
          @filter.safe((b*1.0 / step).truncate * step),
          a
        )
      }
      return self;
    end
    def brightness(t)
      self.apply(){ |r, g, b, a|
          Pixel.new(
          @filter.safe(r + t),
          @filter.safe(g + t),
          @filter.safe(b + t),
          a
        )
      }
      return self;
    end

    def tint(minRGB, maxRGB)
      self.apply(){|r, g, b, a|
        Pixel.new(
          @filter.safe((r - minRGB[0]) * 255*1.0 / (maxRGB[0] - minRGB[0])),
          @filter.safe((g - minRGB[1]) * 255*1.0 / (maxRGB[1] - minRGB[1])),
          @filter.safe((b - minRGB[2]) * 255*1.0 / (maxRGB[2] - minRGB[2])),
          a
        )
      };
      return self;
    end

    def saturation(t)
      self.apply(){|r, g, b, a|
        avg = ( r + g + b ) / 3;
        Pixel.new(
          @filter.safe(avg + t * (r - avg)),
          @filter.safe(avg + t * (g - avg)),
          @filter.safe(avg + t * (b - avg)),
          a
        )
      }
      return self
    end

    def blur
      data = self.convolve([
        [1, 2, 1],
        [2, 2, 2],
        [1, 2, 1]
      ])
      @filter.image.import_pixels(0, 0, @width, @height, "RGBA", data)
      return self
    end
    def gaussianBlur
      data = self.convolve([
        [1*1.0 /273, 4*1.0 /273, 7*1.0 /273, 4*1.0 /273, 1*1.0 /273],
        [4*1.0 /273, 16*1.0 /273, 26*1.0 /273, 16*1.0 /273, 4*1.0 /273],
        [7*1.0 /273, 26*1.0 /273, 41*1.0 /273, 26*1.0 /273, 7*1.0 /273],
        [4*1.0 /273, 16*1.0 /273, 26*1.0 /273, 16*1.0 /273, 4*1.0 /273],
        [1*1.0 /273, 4*1.0 /273, 7*1.0 /273, 4*1.0 /273, 1*1.0 /273]
      ]);
      @filter.image.import_pixels(0, 0, @width, @height, "RGBA", data)
      return self;
    end

    def convolve(kernel)
      if(!kernel)
        #                throw "Kernel was null in convolve function.";
      elsif(kernel.length == 0)
        #                throw "Kernel length was 0 in convolve function.";
      end

      outDArray = []
      inDArray  = @filter.imageData
      kh = Integer(kernel.length / 2)
      kw = Integer(kernel[0].length / 2)

      (0...@height).each do |i|
        (0...@width).each do |j|
          outIndex = i*@width*4 + j*4
          r = g = b = 0
          (-kh..kh).each do |n|
            (-kw..kw).each do |m|
              if(i + n >= 0 && i + n < @height)
                if(j + m >= 0 && j + m < @width)
                  f = kernel[n + kh][m + kw] * 1.0
                  next if f == 0
                  inIndex = (i + n)*@width*4 + (j + m)*4
                  r += (inDArray[inIndex]/POW_CONST * f)
                  g += (inDArray[inIndex + 1]/POW_CONST * f)
                  b += (inDArray[inIndex + 2]/POW_CONST * f)
                end
              end
            end
          end
          outDArray[outIndex]     = @filter.safe(r) * POW_CONST
          outDArray[outIndex + 1] = @filter.safe(g) * POW_CONST
          outDArray[outIndex + 2] = @filter.safe(b) * POW_CONST
          outDArray[outIndex + 3] = 255 * POW_CONST
        end
      end
      return outDArray;
    end
  end

  class Blend
    attr_accessor :filter, :width, :height
    def initialize(filtr)
      @filter = filtr
      @width = filtr.image.columns
      @height = filtr.image.rows
    end
    def apply(topFiltr, &block)
      blendDArray = topFiltr.imageData
      imageDArray = @filter.imageData
      (0...@height).each do |i|
        (0...@width).each do |j|
          index = i*@width*4 + j*4
          rgba = yield(
            Pixel.new(blendDArray[index] / POW_CONST,
              blendDArray[index + 1] / POW_CONST,
              blendDArray[index + 2] / POW_CONST,
              blendDArray[index + 3] / POW_CONST
            ),
            Pixel.new(imageDArray[index] / POW_CONST,
              imageDArray[index + 1] / POW_CONST,
              imageDArray[index + 2] / POW_CONST,
              imageDArray[index + 3] / POW_CONST
            )
          );
          imageDArray[index] = rgba.r * POW_CONST
          imageDArray[index + 1] = rgba.g * POW_CONST
          imageDArray[index + 2] = rgba.b * POW_CONST
          imageDArray[index + 3] = rgba.a * POW_CONST
        end
      end
      @filter.image.import_pixels(0, 0, @width, @height, "RGBA", imageDArray)
    end
    def overlay_calc(b, t)
      return (b > 128) ? 255 - 2 * (255 - t) * (255 - b)*1.0 / 255: (b * t * 2)*1.0 / 255;
    end
    def overlay(topFiltr)
      self.apply(topFiltr) { |top, bottom|
        Pixel.new(
        @filter.safe(overlay_calc(bottom.r, top.r)),
        @filter.safe(overlay_calc(bottom.g, top.g)),
        @filter.safe(overlay_calc(bottom.b, top.b)),
        bottom.a
        )
      }
      return self;
    end
    def softLight_calc(b, t)
      return (b > 128) ? 255 - ((255 - b) * (255 - (t - 128)))*1.0 / 255 : (b * (t + 128))*1.0 / 255;
    end
    def softLight(topFiltr)
      self.apply(topFiltr){ |top, bottom|
        Pixel.new(
        @filter.safe(softLight_calc(bottom.r, top.r)),
        @filter.safe(softLight_calc(bottom.g, top.g)),
        @filter.safe(softLight_calc(bottom.b, top.b)),
        bottom.a
        )
      }
      return self;
    end
    def multiply(topFiltr)
      self.apply(topFiltr){|top, bottom|
        Pixel.new(
          @filter.safe((top.r * bottom.r)*1.0 / 255),
          @filter.safe((top.g * bottom.g)*1.0 / 255),
          @filter.safe((top.b * bottom.b)*1.0 / 255),
          bottom.a
        )
      }
      return self
    end
  end

  class Effect
    def self.e1(url, filterred_filename)
      @filter = Filter.new(url)
      topFiltr = @filter.duplicate
      topFiltr.core.saturation(0).blur
      @filter.blend.multiply(topFiltr)
      @filter.core.tint([60, 35, 10], [170, 140, 160]).contrast(0.8).brightness(10)
      @filter.write_filterred_image(filterred_filename)
    end

    def self.e2(url, filterred_filename)
      @filter = Filter.new(url)
      @filter.core.saturation(0.3).posterize(70).tint([50, 35, 10], [190, 190, 230])
      @filter.write_filterred_image(filterred_filename)
    end

    def self.e3(url, filterred_filename)
      @filter = Filter.new(url)
      @filter.core.tint([60, 35, 10], [170, 170, 230]).contrast(0.8);
      @filter.write_filterred_image(filterred_filename)
    end

    def self.e4(url, filterred_filename)
      @filter = Filter.new(url)
      @filter.core.grayScale().tint([60,60,30], [210, 210, 210])
      @filter.write_filterred_image(filterred_filename)
    end

    def self.e5(url, filterred_filename)
      @filter = Filter.new(url)
      @filter.core.tint([30, 40, 30], [120, 170, 210]).contrast(0.75).bias(1).saturation(0.6).brightness(20)
      @filter.write_filterred_image(filterred_filename)
    end

    def self.e6(url, filterred_filename)
      @filter = Filter.new(url)
      @filter.core.saturation(0.4).contrast(0.75).tint([20, 35, 10], [150, 160, 230])
      @filter.write_filterred_image(filterred_filename)
    end

    def self.e7(url, filterred_filename)
      @filter = Filter.new(url)
      topFiltr = @filter.duplicate()
      topFiltr.core.tint([20, 35, 10], [150, 160, 230]).saturation(0.6)
      @filter.core.adjust(0.1,0.7,0.4).saturation(0.6).contrast(0.8)
      @filter.blend.multiply(topFiltr)
      @filter.write_filterred_image(filterred_filename)
    end

    def self.e8(url, filterred_filename)
      @filter = Filter.new(url)
      topFiltr = @filter.duplicate()
      topFiltr1 = @filter.duplicate()
      topFiltr2 = @filter.duplicate()
      topFiltr2.core.fill(167, 118, 12)
      topFiltr1.core.gaussianBlur()
      topFiltr.core.saturation(0)
      @filter.blend.overlay(topFiltr)
      @filter.blend.softLight(topFiltr1)
      @filter.blend.softLight(topFiltr2)
      @filter.core.saturation(0.5).contrast(0.86)
      @filter.write_filterred_image(filterred_filename)
    end

    def self.e9(url, filterred_filename)
      @filter = Filter.new(url)
      topFiltr = @filter.duplicate();
      topFiltr1 = @filter.duplicate();
      topFiltr1.core.fill(226, 217, 113).saturation(0.2);
      topFiltr.core.gaussianBlur().saturation(0.2);
      topFiltr.blend.multiply(topFiltr1);
      @filter.core.saturation(0.2).tint([30, 45, 40], [110, 190, 110]);
      @filter.blend.multiply(topFiltr);
      @filter.core.brightness(20).sharpen().contrast(1.1);
      @filter.write_filterred_image(filterred_filename)
    end

    def self.e10(url, filterred_filename)
      @filter = Filter.new(url)
      @filter.core.sepia().bias(0.6)
      @filter.write_filterred_image(filterred_filename)
    end
  end
end
