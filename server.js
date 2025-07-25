const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors'); 
const multer = require('multer');
const path = require('path');

const app = express();
const PORT = 3000;

// Middleware
app.use(cors({
  origin: '*', // Allow all origins
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], // Allow all methods
  allowedHeaders: ['Content-Type', 'Authorization'], // Allow common headers
  credentials: true // Allow credentials
}));
app.use(express.json());
app.use('/uploads', express.static('uploads'));

// Multer configuration for image uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});

const upload = multer({ storage: storage });

// MongoDB connection
mongoose.connect('mongodb://127.0.0.1:27017/bookmanager', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});
const db = mongoose.connection;
db.on('error', console.error.bind(console, '❌ MongoDB connection error:'));
db.once('open', () => console.log('✅ Connected to MongoDB'));

// Book schema & model
const bookSchema = new mongoose.Schema({
  title: String,
  author: String,
  year: String,
  imageUrl: String,
});
const Book = mongoose.model('Book', bookSchema);

// Routes
app.get('/api/books', async (req, res) => {
  try {
    const books = await Book.find();
    res.json(books);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch books.' });
  }
});

app.post('/api/books', upload.single('image'), async (req, res) => {
  try {
    const { title, author, year } = req.body;
    if (!title || !author || !year) {
      return res.status(400).json({ error: 'All fields are required.' });
    }
    const imageUrl = req.file ? `/uploads/${req.file.filename}` : null;
    const newBook = new Book({
      title,
      author,
      year,
      imageUrl
    });
    await newBook.save();
    res.status(201).json(newBook);
  } catch (err) {
    res.status(500).json({ error: 'Failed to add book.' });
  }
});

app.put('/api/books/:id', upload.single('image'), async (req, res) => {
  try {
    const { title, author, year } = req.body;
    if (!title || !author || !year) {
      return res.status(400).json({ error: 'All fields are required.' });
    }
    const updateData = {
      title,
      author,
      year
    };
    if (req.file) {
      updateData.imageUrl = `/uploads/${req.file.filename}`;
    }
    const updatedBook = await Book.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true }
    );
    if (!updatedBook) {
      return res.status(404).json({ error: 'Book not found.' });
    }
    res.json(updatedBook);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update book.' });
  }
});

app.delete('/api/books/:id', async (req, res) => {
  try {
    const deleted = await Book.findByIdAndDelete(req.params.id);
    if (!deleted) {
      return res.status(404).json({ error: 'Book not found.' });
    }
    res.status(204).send();
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete book.' });
  }
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`📚 Server running at http://0.0.0.0:${PORT}`);
  console.log(`📚 Access from other devices: http://192.168.193.69:${PORT}`);
});
