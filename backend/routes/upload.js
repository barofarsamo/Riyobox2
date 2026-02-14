const express = require('express');
const multer = require('multer');
const { PutObjectCommand, ListObjectsV2Command, DeleteObjectCommand, GetObjectCommand } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');
const { r2Client } = require('../utils/r2Config');
const { protect, adminOnly } = require('../middleware/authMiddleware');
const router = express.Router();

const storage = multer.memoryStorage();
const upload = multer({
  storage,
  limits: {
    fileSize: 500 * 1024 * 1024, // 500MB limit for videos
  }
});

// Upload file to R2
router.post('/', protect, adminOnly, upload.single('file'), async (req, res) => {
  if (!req.file) return res.status(400).json({ message: 'No file uploaded' });

  const fileName = `${Date.now()}-${req.file.originalname}`;
  const contentType = req.file.mimetype;

  try {
    await r2Client.send(
      new PutObjectCommand({
        Bucket: process.env.R2_BUCKET_NAME,
        Key: fileName,
        Body: req.file.buffer,
        ContentType: contentType,
      })
    );

    // If bucket is public, we can just return the URL
    const publicUrl = `${process.env.R2_S3_ENDPOINT}/${process.env.R2_BUCKET_NAME}/${fileName}`;

    res.status(201).json({
      message: 'File uploaded successfully',
      url: publicUrl,
      key: fileName
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// List all objects in R2 bucket
router.get('/', protect, adminOnly, async (req, res) => {
  try {
    const data = await r2Client.send(
      new ListObjectsV2Command({
        Bucket: process.env.R2_BUCKET_NAME,
      })
    );

    const files = data.Contents?.map(file => ({
      key: file.Key,
      size: file.Size,
      lastModified: file.LastModified,
      url: `${process.env.R2_S3_ENDPOINT}/${process.env.R2_BUCKET_NAME}/${file.Key}`
    })) || [];

    res.json(files);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Delete an object from R2
router.delete('/:key', protect, adminOnly, async (req, res) => {
  try {
    await r2Client.send(
      new DeleteObjectCommand({
        Bucket: process.env.R2_BUCKET_NAME,
        Key: req.params.key,
      })
    );
    res.json({ message: 'File deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Generate a signed URL for an object (valid for 1 hour)
router.get('/signed-url/:key', protect, async (req, res) => {
  try {
    const command = new GetObjectCommand({
      Bucket: process.env.R2_BUCKET_NAME,
      Key: req.params.key,
    });
    const url = await getSignedUrl(r2Client, command, { expiresIn: 3600 });
    res.json({ url });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
