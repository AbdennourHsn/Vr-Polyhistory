using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DisplayPath : MonoBehaviour
{
    SpriteRenderer sprite;
    Color a;
    public float A;
    public bool Dir;
    // Start is called before the first frame update
    void Start()
    {
        sprite = this.gameObject.GetComponent<SpriteRenderer>();

        
    
        
        
    }

  


    IEnumerator color(){
        yield return null;

    }



    private void Update()
    {
        Vector4 C = sprite.color;


        if (!Dir) A += (0.7f*Time.deltaTime);
        else A -= (0.7f * Time.deltaTime);


        sprite.color = new Vector4(C.x,C.y,C.z,A);

        if (A >= 1) Dir = true;
        if (A <= 0) Dir = false;
    }

}
