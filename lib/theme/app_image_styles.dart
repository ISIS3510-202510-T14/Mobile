import 'package:flutter/material.dart';

/// Demonstration of best practices from:
/// ## 7. Working With Images
///
/// 1) Use good photos
/// 2) Ensure text contrast
/// 3) Respect intended size
/// 4) Beware user-uploaded content
///
/// This screen shows multiple approaches for implementing each guideline in Flutter.
class AppImageStyle extends StatelessWidget {
  const AppImageStyle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Working With Images Demo'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1) GOOD PHOTOS & TEXT CONTRAST
            //
            // Example: A high-quality stock image from unsplash.com
            // We add a black overlay to ensure white text remains legible.
            //
            // "Black overlay tones down light areas, making light text stand out."
            Container(
              margin: const EdgeInsets.all(16),
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1633113212239-4f8a80701e9e' 
                    '?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8YmVhdXRpZnVsJTIw'
                    'bGFuZHNjYXBlfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=800&q=60',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Semi-transparent overlay
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  // Text layered on top
                  Center(
                    child: Text(
                      'Beautiful Landscape',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        shadows: [
                          // Subtle glow-like text shadow
                          Shadow(
                            color: Colors.black.withOpacity(0.8),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),

            // 2) SHOWING "INTENDED SIZE" for icons
            //
            // - "Don’t scale up icons" beyond their intended design size.
            // - If we need a bigger clickable area, we enclose the icon in a shaped container.
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Good usage: an icon inside a container, but the actual icon
                  // remains at 24px (typical Material icon size) to preserve quality.
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      size: 24, // Do not scale up to e.g. 72 if the design is 24px
                    ),
                  ),
                  // If we truly need a bigger icon, we might use an
                  // actual higher-resolution asset or an SVG designed for that size.
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      size: 48, // If absolutely needed, ensure it's high-res
                    ),
                  ),
                ],
              ),
            ),

            // 3) PARTIAL SCREENSHOTS - to avoid scaling down screenshots too much
            //
            // For demonstration, we have a "fake" screenshot image from unsplash.
            // We only show part of it, or a smaller layout variant, so text remains legible.
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.all(16),
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  // Another sample, imagine this is an "app screenshot"
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1504147432389-4c0763e9bc40'
                    '?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=60',
                  ),
                  // We only show 'cover', not the entire image, avoiding excessive scaling
                  fit: BoxFit.cover,
                  alignment: Alignment(-0.1, 0.0), // partial area of the image
                ),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.7),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Partial Screenshot Preview',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),

            // 4) USER-UPLOADED CONTENT
            //
            // We place the image in a container with BoxFit.cover so it’s cropped
            // rather than distorting or messing up the layout. This approach is also
            // commonly used with a circle avatar or something similar.
            // Also adding a subtle border or box-shadow to avoid "background bleed."
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User-Uploaded Image',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 150,
                    width: double.infinity,
                    // Subtle "inner" shadow or border approach:
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      // If user content is unpredictable, we do cover:
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://source.unsplash.com/random/800x600'
                          '?person,portrait', 
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        // Optionally overlay to unify the look or tone
                        color: Colors.black.withOpacity(0.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "We center & crop this user-provided image so it doesn't break the layout. "
                    "No scaling beyond its natural size, ensuring we maintain clarity.",
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
