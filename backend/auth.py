from sqlalchemy.orm import Session
from passlib.context import CryptContext
from models import User


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# bcrypt hard limit = 72 bytes
def hash_password(password: str) -> str:
    return pwd_context.hash(password[:72])

def verify_password(password: str, password_hash: str) -> bool:
    return pwd_context.verify(password[:72], password_hash)

def signup_user(db: Session, name: str, phone: str, password: str) -> User:
    existing_user = db.query(User).filter(User.phone == phone).first()
    if existing_user:
        raise ValueError("Phone already registered")

    user = User(
        name=name,
        phone=phone,
        password_hash=hash_password(password),
    )

    db.add(user)
    db.commit()
    db.refresh(user)
    return user

def login_user(db: Session, phone: str, password: str) -> User:
    user = db.query(User).filter(User.phone == phone).first()

    if not user:
        raise ValueError("Invalid credentials")

    if not verify_password(password, user.password_hash):
        raise ValueError("Invalid credentials")

    return user

def get_user_profile(db: Session, phone: str):
    user = db.query(User).filter(User.phone == phone).first()
    if not user:
        raise ValueError("User not found")

    return {
    "name": user.name,
    "phone": user.phone,
    "language": user.language
    }


def update_user_profile(db: Session, phone: str, name: str, language: str):
    user = db.query(User).filter(User.phone == phone).first()
    if not user:
        raise ValueError("User not found")

    user.name = name
    user.language = language

    db.commit()
    db.refresh(user)

    return {
        "name": user.name,
        "phone": user.phone,
        "language": user.language
    }




pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def change_user_password(
    db: Session,
    phone: str,
    current_password: str,
    new_password: str
):
    user = db.query(User).filter(User.phone == phone).first()
    if not user:
        raise ValueError("User not found")

    # Verify current password
    if not pwd_context.verify(current_password, user.password_hash):
        raise ValueError("Incorrect current password")

    # Hash and update new password
    user.password_hash = pwd_context.hash(new_password)
    db.commit()

    return True
