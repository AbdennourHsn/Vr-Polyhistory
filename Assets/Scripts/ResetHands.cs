using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ResetHands : MonoBehaviour
{
    HandAnimationControl[] hand;
    private void Start()
    {
        hand = FindObjectsOfType<HandAnimationControl>();
    }
    public void Rasethands()
    {
        foreach(HandAnimationControl h in hand )
            for(int i=0;i<10;i++) h.Reset();
    }
}
